use strictures 2;

use Test2::V0;

use Test::Perl::Critic (-profile => '.perlcriticrc');

all_critic_ok();
