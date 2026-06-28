use strictures 2;

use Cwd        qw(abs_path);
use File::Temp qw(tempdir);
use FindBin;
use Test2::V0;

my $style_root = abs_path("$FindBin::Bin/..");
my @repo_roots = (tempdir(CLEANUP => 1), tempdir(CLEANUP => 1),);

for my $repo_root (@repo_roots) {
  system('git', 'init', '-q', $repo_root) == 0
    or die "Cannot initialize temporary git repo";
}

system("$style_root/tools/install-git-hooks", @repo_roots) == 0
  or die "install-git-hooks failed";

for my $repo_root (@repo_roots) {
  chomp(my $hooks_path = `git -C "$repo_root" config --get core.hooksPath`);
  is $hooks_path, "$style_root/configs/git-hooks", 'core.hooksPath points at shared hooks';
}

done_testing();
