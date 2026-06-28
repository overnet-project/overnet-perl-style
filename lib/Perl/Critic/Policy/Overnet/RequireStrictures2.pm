package Perl::Critic::Policy::Overnet::RequireStrictures2;

use strictures 2;

use Perl::Critic::Utils qw(:severities);
use parent 'Perl::Critic::Policy';

our $VERSION = '0.001';

my $DESC = 'Use strictures 2';
my $EXPL = 'Overnet Perl code must enable strictures with exactly "use strictures 2;"';

sub default_severity { return $SEVERITY_HIGHEST }
sub default_themes   { return qw(overnet bugs) }
sub applies_to       { return 'PPI::Document' }

sub violates {
  my ($self, undef, $document) = @_;

  my $filename = $document->filename || '';
  return if $filename =~ m{(?:\A|/)Makefile[.]PL\z}xm;

  my $includes = $document->find('PPI::Statement::Include') || [];
  for my $include (@{$includes}) {
    next unless $include->parent->isa('PPI::Document');
    next unless ($include->type || '') eq 'use';
    next unless (($include->module || $include->pragma || '') eq 'strictures');
    return if $include->content =~ /\Ause\s+strictures\s+2\s*;\z/mx;
  }

  return $self->violation($DESC, $EXPL, _first_statement_or_document($document));
}

sub _first_statement_or_document {
  my ($document) = @_;
  my $statements = $document->find('PPI::Statement') || [];
  return $statements->[0] || $document;
}

1;
