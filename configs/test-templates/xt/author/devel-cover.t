use strictures 2;

use Cwd            qw(abs_path);
use File::Basename qw(dirname);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin;
use Test2::V0;

# Coverage collection is slow and needs Devel::Cover, so it is opt-in: it runs
# only when OVERNET_COVERAGE is set (a coverage CI job sets it). A normal
# `prove xt/author/` run skips it.
if (!$ENV{OVERNET_COVERAGE}) {
  plan skip_all => 'set OVERNET_COVERAGE=1 to run the coverage gate';
}
if (!eval { require Devel::Cover; require Devel::Cover::DB; 1 }) {
  plan skip_all => 'Devel::Cover is not installed';
}

my $ROOT  = abs_path("$FindBin::Bin/../..");
my $PERL  = $^X;
my $PROVE = _tool('prove');

# Per-file floors for everything under lib/. This template is synced verbatim
# across repos, so repos tune the floors through the environment instead of
# editing the file: stricter gates for security-critical code, or temporarily
# lower ones used as a ratchet while coverage is being raised.
my %MIN = (
  statement  => $ENV{OVERNET_COVERAGE_MIN_STATEMENT}  // 85,
  branch     => $ENV{OVERNET_COVERAGE_MIN_BRANCH}     // 60,
  subroutine => $ENV{OVERNET_COVERAGE_MIN_SUBROUTINE} // 90,
);

chdir $ROOT or die "chdir $ROOT: $!";

my $db_dir = File::Spec->catdir(tempdir(CLEANUP => 1), 'cover_db');

my @tests = sort glob 't/*.t';
ok scalar(@tests), 'found test files to run under coverage' or bail_out('no tests to cover');

{
  # Collect every criterion; restricting collection to a subset skews branch
  # data. The report step below is what filters to the metrics we gate on.
  # PERL5LIB is inherited so sibling repo libs stay visible to the suite.
  local $ENV{HARNESS_PERL_SWITCHES} = "-MDevel::Cover=-db,$db_dir,-silent,1";
  my $status = system $PERL, $PROVE, '-Ilib', @tests;
  is $status, 0, 'the test suite passes under coverage instrumentation';
}

my %coverage = _read_coverage($db_dir);
ok scalar(keys %coverage), 'coverage was collected for lib/'
  or bail_out('no lib/ coverage rows were produced');

for my $file (sort keys %coverage) {
  for my $metric (sort keys %MIN) {
    my $got   = $coverage{$file}{$metric};
    my $shown = $got // 'missing';
    ok defined($got) && $got >= $MIN{$metric}, "$file: $metric coverage $shown% >= $MIN{$metric}%"
      or diag "coverage shortfall in $file for $metric";
  }
}

done_testing;

sub _tool {
  my ($name) = @_;
  my $beside = File::Spec->catfile(dirname($PERL), $name);
  return -x $beside ? $beside : $name;
}

sub _read_coverage {
  my ($dir) = @_;

  # Read the database directly instead of parsing `cover -summary` output,
  # which truncates long file names and would silently drop files from the
  # gate. Only lib/ modules are gated; the suite's own t/ files are not.
  # Known limitation: a module the suite never loads produces no coverage
  # rows at all, so it escapes the gate rather than failing it.
  my $db = Devel::Cover::DB->new(db => $dir);
  $db = $db->merge_runs;
  $db->calculate_summary(statement => 1, branch => 1, subroutine => 1);

  my %seen;
  for my $file (grep { m{\Alib/}xms } $db->cover->items) {
    $seen{$file} = { map { $_ => _percentage($db, $file, $_) } qw(statement branch subroutine) };
  }
  return %seen;
}

sub _percentage {
  my ($db, $file, $metric) = @_;
  my $value = $db->summary($file, $metric, 'percentage');

  # A file with no branches has no branch percentage; treat that as covered.
  return defined $value ? 0 + sprintf('%.1f', $value) : 100;
}
