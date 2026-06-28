use strictures 2;

use Test2::V0;

use lib 't/lib';

use OvernetPerlCriticPolicyTest qw(has_policy);

my $strictures_policy = 'Perl::Critic::Policy::Overnet::RequireStrictures2';

ok !has_policy("use strictures 2;\n1;\n", $strictures_policy), 'strictures 2 satisfies the Overnet strictures policy';
ok has_policy("use strict;\nuse warnings;\n1;\n", $strictures_policy),
  'strict plus warnings does not satisfy the Overnet strictures policy';
ok has_policy("use strictures;\n1;\n", $strictures_policy),
  'strictures without a version violates the Overnet strictures policy';
ok has_policy("use strictures 1;\n1;\n", $strictures_policy),
  'strictures version 1 violates the Overnet strictures policy';
ok !has_policy("use strict;\nuse warnings;\n1;\n", $strictures_policy, 'Makefile.PL'),
  'Makefile.PL is exempt from the Overnet strictures policy';

done_testing();
