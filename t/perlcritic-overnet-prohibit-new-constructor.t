use strictures 2;

use Test2::V0;

use lib 't/lib';

use OvernetPerlCriticPolicyTest qw(has_policy);

my $new_policy = 'Perl::Critic::Policy::Overnet::ProhibitNewConstructor';

ok !has_policy("use strictures 2;\nuse Moo;\nhas name => (is => 'ro');\n1;\n", $new_policy),
  'Moo-generated constructors satisfy the Overnet constructor policy';
ok has_policy("use strictures 2;\nsub new { return bless {}, shift; }\n1;\n", $new_policy),
  'sub new violates the Overnet constructor policy';
ok has_policy("use strictures 2;\nsub Overnet::Thing::new { return bless {}, shift; }\n1;\n", $new_policy),
  'fully qualified sub new violates the Overnet constructor policy';
ok !has_policy("use strictures 2;\nsub renew { return 1; }\nmy \$object = Overnet::Thing->new;\n1;\n",
  $new_policy),
  'non-constructor subs and new calls do not violate the Overnet constructor policy';
ok has_policy("use strictures 2;\n*new = sub { return 1; };\n1;\n", $new_policy),
  'typeglob assignment to new violates the Overnet constructor policy';
ok has_policy("use strictures 2;\n*Overnet::Thing::new = sub { return 1; };\n1;\n", $new_policy),
  'fully qualified typeglob assignment to new violates the Overnet constructor policy';
ok has_policy("use strictures 2;\nlocal *new = sub { return 1; };\n1;\n", $new_policy),
  'localized typeglob assignment to new violates the Overnet constructor policy';
ok has_policy("use strictures 2;\nBEGIN { *new = sub { return 1; }; }\n1;\n", $new_policy),
  'BEGIN-time typeglob assignment to new violates the Overnet constructor policy';
ok has_policy("use strictures 2;\nsub factory { return 1; }\n*new = \\&factory;\n1;\n", $new_policy),
  'typeglob aliasing to new violates the Overnet constructor policy';
ok !has_policy("use strictures 2;\nmy \$name = 'sub new';\n# sub new in comments is fine\n1;\n", $new_policy),
  'sub new in strings and comments does not violate the Overnet constructor policy';
ok !has_policy("use strictures 2;\nmy \$has_new = defined *new{CODE};\n1;\n", $new_policy),
  'typeglob introspection for new does not violate the Overnet constructor policy';

done_testing();
