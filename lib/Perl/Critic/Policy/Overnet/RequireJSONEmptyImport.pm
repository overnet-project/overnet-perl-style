package Perl::Critic::Policy::Overnet::RequireJSONEmptyImport;

use strictures 2;

use Perl::Critic::Utils qw(:severities);
use parent 'Perl::Critic::Policy';

our $VERSION = '0.001';

my $DESC = 'Use JSON ()';
my $EXPL = 'Overnet Perl code must import JSON with exactly "use JSON ();"';

sub default_severity { return $SEVERITY_HIGHEST }
sub default_themes   { return qw(overnet bugs) }
sub applies_to       { return 'PPI::Statement::Include' }

sub violates {
  my ($self, $include, undef) = @_;

  return unless ($include->type || '') eq 'use';
  return unless (($include->module || '') eq 'JSON');
  return if $include->content =~ /\Ause\s+JSON\s*\(\s*\)\s*;\z/mx;

  return $self->violation($DESC, $EXPL, $include);
}

1;
