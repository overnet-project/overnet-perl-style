use strictures 2;

use FindBin;
use Test2::V0;

my $template = "$FindBin::Bin/../configs/test-templates/xt/author/mutation.t";

ok -f $template, 'mutation template exists' or bail_out('no template to inspect');

open my $handle, '<', $template
  or die "Cannot open $template: $!";

my $content = do { local $/; <$handle> };

like $content, qr/\Quse strictures 2;\E/xm, 'template uses strictures 2';
like $content, qr/\QTest2::V0\E/xm,         'template uses Test2::V0';

like $content, qr/skip_all/xm,                        'template can skip itself';
like $content, qr/\$ENV\{OVERNET_MUTATION\}/xm,       'mutation is opt-in via OVERNET_MUTATION';
like $content, qr/\QDevel::Mutator\E/xm,              'template drives Devel::Mutator';
like $content, qr/\Qrequire Devel::Mutator\E/xm,      'template skips when Devel::Mutator is unavailable';
like $content, qr/\QOVERNET_MUTATION_FILES\E/xm,      'the target module list is required and explicit';
like $content, qr/\QOVERNET_MUTATION_TEST_COMMAND\E/xm, 'the per-mutant test command is configurable';

like $content, qr/tempdir/xm,       'the run is isolated in a throwaway work tree';
like $content, qr/File::Spec->updir/xm,
  'the work tree sits beside the repo so sibling-relative paths still resolve';
like $content, qr/\QResult:\E/xm,   'the Devel::Mutator result line is parsed';
like $content, qr/\$survivors/xm,   'surviving mutants are counted and gated';
like $content, qr/baseline/xm,      'the unmutated suite is checked green before mutating';

done_testing();
