use strictures 2;

use Test2::V0;

use lib 't/lib';

use OvernetPerlCriticPolicyTest qw(has_policy);

my $test2_policy = 'Perl::Critic::Policy::Overnet::RequireTest2InTests';

ok !has_policy("use strictures 2;\nuse Test2::V0;\n1;\n", $test2_policy, 'sample.t'),
  'Test2::V0 satisfies the Overnet test policy';
ok has_policy("use strictures 2;\nuse Test2::Bundle::Extended;\n1;\n", $test2_policy, 'sample.t'),
  'Test2 modules other than Test2::V0 do not satisfy the Overnet test policy';
ok has_policy("use strictures 2;\nuse Test::More;\n1;\n", $test2_policy, 'sample.t'),
  'Test::More does not satisfy the Overnet test policy';
ok has_policy("use strictures 2;\nuse Test2::V0;\nuse Test::More;\n1;\n", $test2_policy, 'sample.t'),
  'Test::More violates the Overnet test policy even with Test2::V0';
ok has_policy("use strictures 2;\n1;\n", $test2_policy, 'sample.t'),
  'test files without Test2::V0 violate the Overnet test policy';
ok has_policy("use strictures 2;\nuse Test::More;\n1;\n", $test2_policy, 'sample.pl'),
  'Test::More violates the Overnet test policy outside .t files';
ok !has_policy("use strictures 2;\n1;\n", $test2_policy, 'sample.pl'),
  'non-test files are ignored by the Overnet test policy';

done_testing();
