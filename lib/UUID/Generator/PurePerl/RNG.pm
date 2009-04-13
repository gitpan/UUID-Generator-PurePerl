package UUID::Generator::PurePerl::RNG;

use strict;
use warnings;

my $singleton;
sub singleton {
    my $class = shift;

    if (! defined $singleton) {
        $singleton = $class->new(@_);
    }

    return $singleton;
}

sub new {
    shift;  # class

    my @classes = qw(
        UUID::Generator::PurePerl::RNG::MRMT
        UUID::Generator::PurePerl::RNG::MRMTPP
        UUID::Generator::PurePerl::RNG::rand
    );

    foreach my $class (@classes) {
        next if ! eval qq{ require $class };

        next if ! $class->enabled;

        return $class->new();
    }

    return;
}

1;
__END__

=head1 NAME

UUID::Generator::PurePerl::RNG - Random Number Generator

=head1 DESCRIPTION

UUID::Generator::PurePerl::RNG is Random Number Generator.

INTERNAL USE ONLY.

=head1 AUTHOR

ITO Nobuaki E<lt>banb@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
