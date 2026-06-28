use strictures 2;

use Test2::V0;

use lib 't/lib';

use OvernetPerlCriticPolicyTest qw(has_policy);

my $json_policy = 'Perl::Critic::Policy::Overnet::RequireJSONEmptyImport';

ok !has_policy("use strictures 2;\nuse JSON ();\n1;\n", $json_policy),
  'JSON empty import satisfies the Overnet JSON policy';
ok has_policy("use strictures 2;\nuse JSON;\n1;\n", $json_policy),
  'JSON default import violates the Overnet JSON policy';
ok has_policy("use strictures 2;\nuse JSON qw(encode_json);\n1;\n", $json_policy),
  'JSON named import violates the Overnet JSON policy';

done_testing();
