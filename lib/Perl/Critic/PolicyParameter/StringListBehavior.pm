##############################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
##############################################################################

package Perl::Critic::PolicyParameter::StringListBehavior;

use strict;
use warnings;
use Carp qw(confess);
use Perl::Critic::Utils qw{ :characters &words_from_string &hashify };

use base qw{ Perl::Critic::PolicyParameter::Behavior };

our $VERSION = 1.04;

#-----------------------------------------------------------------------------

sub initialize_parameter {
    my ($self, $parameter, $specification) = @_;

    my $policy_variable_name = q{_} . $parameter->get_name();

    my @always_present_values;

    my $always_present_values = $specification->{list_always_present_values};
    $parameter->_get_behavior_values()->{always_present_values} =
        $always_present_values;

    if ( $always_present_values ) {
        @always_present_values = @{$always_present_values};
    }

    $parameter->_set_parser(
        sub {
            # Normally bad thing, obscuring a variable in a outer scope
            # with a variable with the same name is being done here in
            # order to remain consistent with the parser function interface.
            my ($policy, $parameter, $config_string) = @_;

            my @values = @always_present_values;
            my $value_string = $parameter->get_default_string();

            if (defined $config_string) {
                $value_string = $config_string;
            }

            if ( defined $value_string ) {
                push @values, words_from_string($value_string);
            }

            my %values = hashify(@values);

            $policy->{ $policy_variable_name } = \%values;
            return;
        }
    );

    return;
}

#-----------------------------------------------------------------------------

sub generate_parameter_description {
    my ($self, $parameter) = @_;

    my $always_present_values =
        $parameter->_get_behavior_values()->{always_present_values};

    my $description = $parameter->_get_description_with_trailing_period();
    if ( $description and $always_present_values ) {
        $description .= qq{\n};
    }

    if ( $always_present_values ) {
        $description .= 'Values that are always included: ';
        $description .= join ', ', sort @{ $always_present_values };
        $description .= $PERIOD;
    }

    return $description;
}

1;

__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords

=head1 NAME

Perl::Critic::PolicyParameter::StringListBehavior - Actions appropriate for a parameter that is a list of strings.


=head1 DESCRIPTION

Provides a standard set of functionality for a string list
L<Perl::Critic::PolicyParameter> so that the developer of a policy
does not have to provide it her/himself.


=head1 METHODS

=over

=item C<initialize_parameter( $parameter, $specification )>

Plug in the functionality this behavior provides into the parameter,
based upon the configuration provided by the specification.

This behavior looks for one configuration item:

=over

=item always_present_values

Optional.  Values that should always be included, regardless of what
the configuration of the parameter specifies, as an array reference.

=back

=item C<generate_parameter_description( $parameter )>

Create a description of the parameter, based upon the description on
the parameter itself, but enhancing it with information from this
behavior.

In this specific case, the always present values are added at the end.

=back


=head1 AUTHOR

Elliot Shank <perl@galumph.org>

=head1 COPYRIGHT

Copyright (c) 2006-2007 Elliot Shank.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
