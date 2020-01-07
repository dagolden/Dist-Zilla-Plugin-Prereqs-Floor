use v5.10;
use strict;
use warnings;

package Dist::Zilla::Plugin::Prereqs::Floor;
# ABSTRACT: Dist::Zilla plugin to set a minimum allowed version for prerequisites

our $VERSION = '0.003';

use Moose;

use Dist::Zilla 5;

with 'Dist::Zilla::Role::PrereqSource';

has _floor => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

sub BUILDARGS {
    my ( $class, @arg ) = @_;
    my %copy = ref $arg[0] ? %{ $arg[0] } : @arg;

    my $zilla = delete $copy{zilla};
    my $name  = delete $copy{plugin_name};

    return {
        zilla       => $zilla,
        plugin_name => $name,
        _floor      => \%copy,
    };
}

sub register_prereqs {
    my ($self) = @_;

    $self->log("Checking module prerequisites against minimum floor");

    my $zilla = $self->zilla;
    my $floor = $self->_floor;

    return unless %$floor;

    my $prereqs = $zilla->prereqs->cpan_meta_prereqs->as_string_hash;

    foreach my $phase ( sort keys %$prereqs ) {
        foreach my $rel ( sort keys %{ $prereqs->{$phase} } ) {
            foreach my $mod ( sort keys %{ $prereqs->{$phase}{$rel} } ) {
                next if $mod eq 'perl'; # obvious
                if ( my $ver = $floor->{$mod} ) {
                    $self->log_debug("$phase/$rel: $mod minimum set to $ver");
                    $self->zilla->register_prereqs(
                        {
                            phase => $phase,
                            type  => $rel,
                        },
                        $mod => $ver,
                    );
                }
            }
        }
    }
    return;
}

__PACKAGE__->meta->make_immutable;
1;

=for Pod::Coverage BUILDARGS register_prereqs mvp_multivalue_args

=head1 SYNOPSIS

    ; in dist.ini

    [Prereqs::Floor]
    File::Temp = 0.19
    Test::More = 0.86

=head1 DESCRIPTION

This prereq provider sets a minimum allowed version for the specified
modules.

If the module has been listed as a prerequisite for any phase ('runtime',
'test', etc.) or type ('requires', 'recommends', etc.), the listed minimum
version will be applied to that phase and type.

The prereqs will B<only> be applied if they already exist.  This will not
add any new prerequisites.

This prereq provider should run B<last>.  Any prerequisites added after it
runs won't be updated.

=head1 SEE ALSO

=for :list
* L<Prereqs::Upgrade|Dist::Zilla::Plugin::Prereqs::Upgrade> – similar
  concept with very flexible phase and type mapping, but harder to apply
  universally across all phases/types at once

=cut

# vim: ts=4 sts=4 sw=4 et tw=75:
