package UUID::Generator::PurePerl::RNG::rand;

use strict;
use warnings;

use base qw( UUID::Generator::PurePerl::RNG::Bridge );

sub enabled { 1 }

sub new {
    my $class = shift;
    my $seed  = shift;
    $seed = time if ! defined $seed;

    my $me = q{};
    my $self = \$me;

    srand $seed;

    return bless $self, $class;
}

sub rand_32bit {
    my $v1 = int(rand(65536)) % 65536;
    my $v2 = int(rand(65536)) % 65536;
    return ($v1 << 16) | $v2;
}

1;
__END__

=head1 NAME

UUID::Generator::PurePerl::RNG::rand - RNG bridge of CORE rand() function

=head1 DESCRIPTION

UUID::Generator::PurePerl::RNG::rand is RNG bridge interface of rand() Perl CORE function.

=head1 AUTHOR

ITO Nobuaki E<lt>banb@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
