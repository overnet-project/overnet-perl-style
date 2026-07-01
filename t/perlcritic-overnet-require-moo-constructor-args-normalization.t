use strictures 2;

use Test2::V0;

use lib 't/lib';

use OvernetPerlCriticPolicyTest qw(has_policy);

my $policy =
  'Perl::Critic::Policy::Overnet::RequireMooConstructorArgsNormalization';

ok !has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  my (\$class, \@args) = \@_;\n  my %args = _constructor_args_hash(\@args);\n  return \\%args;\n}\n1;\n",
    $policy,
  ),
  'BUILDARGS may capture raw constructor args as @args';

ok !has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  my \$class = shift;\n  my \@args = \@_;\n  return _normalize(\@args);\n}\n1;\n",
    $policy,
  ),
  'BUILDARGS may shift class and preserve remaining args as @args';

ok !has_policy(
"use strictures 2;\nuse Moo;\naround new => sub {\n  my (\$orig, \$class, \@args) = \@_;\n  my %args = _constructor_args_hash(\@args);\n  return \$class->SUPER::new(%args);\n};\n1;\n",
    $policy,
  ),
  'around new may capture raw constructor args as @args';

ok !has_policy(
"use strictures 2;\nsub helper {\n  my (\$class, %args) = \@_;\n  return \\%args;\n}\n1;\n",
    $policy,
  ),
  'non-constructor methods may use %args';

ok !has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  my (\$class, \@args) = \@_;\n  my %args = \@args;\n  return \\%args;\n}\n1;\n",
    $policy,
  ),
  'normalized @args may be converted to %args later';

ok !has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  my (\$class, \@args) = \@_;\n  my \$helper = sub {\n    my %args = \@_;\n    return \\%args;\n  };\n  return _normalize(\@args);\n}\n1;\n",
    $policy,
  ),
'nested helper closures inside BUILDARGS are not constructor arg normalization';

ok has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  my (\$class, %args) = \@_;\n  return \\%args;\n}\n1;\n",
    $policy,
  ),
  'BUILDARGS must not destructure @_ directly into %args';

ok has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  my %args = \@_;\n  return \\%args;\n}\n1;\n",
    $policy,
  ),
  'BUILDARGS must not assign @_ directly into %args';

ok has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  my \$class = shift;\n  my %args = \@_;\n  return \\%args;\n}\n1;\n",
    $policy,
  ),
  'BUILDARGS must not shift class and assign remaining @_ directly into %args';

ok has_policy(
"use strictures 2;\nuse Moo;\nsub BUILDARGS {\n  shift;\n  my %args = \@_;\n  return \\%args;\n}\n1;\n",
    $policy,
  ),
  'BUILDARGS must not use implicit shift then direct %args assignment';

ok has_policy(
"use strictures 2;\nuse Moo;\naround new => sub {\n  my (\$orig, \$class, %args) = \@_;\n  return \$class->SUPER::new(%args);\n};\n1;\n",
    $policy,
  ),
  'around new must not destructure @_ directly into %args';

ok has_policy(
"use strictures 2;\nuse Moo;\naround new => sub {\n  my \$orig = shift;\n  my \$class = shift;\n  my %args = \@_;\n  return \$class->SUPER::new(%args);\n};\n1;\n",
    $policy,
  ),
'around new must not shift wrapper args and assign remaining @_ directly into %args';

ok has_policy(
"use strictures 2;\nuse Moo;\naround 'new' => sub {\n  my (\$orig, \$class, %args) = \@_;\n  return \$class->SUPER::new(%args);\n};\n1;\n",
    $policy,
  ),
  'quoted around new is covered';

ok has_policy(
"use strictures 2;\nuse Moo;\naround [qw(new close)] => sub {\n  my (\$orig, \$class, %args) = \@_;\n  return \$class->SUPER::new(%args);\n};\n1;\n",
    $policy,
  ),
  'arrayref around new is covered';

ok !has_policy(
"use strictures 2;\nmy \$sample = 'my (\$class, %args) = \@_';\n# sub BUILDARGS { my %args = \@_; }\n1;\n",
    $policy,
  ),
  'strings and comments do not violate the constructor args policy';

done_testing();
