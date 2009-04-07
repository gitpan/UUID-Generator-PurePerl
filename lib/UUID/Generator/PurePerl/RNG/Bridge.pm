package UUID::Generator::PurePerl::RNG::Bridge;

use strict;
use warnings;

use Digest;

sub gen_seed_32bit {
    my $d = Digest->new('MD5');
    $d->add(pack('I', time));
    my $r = $d->digest;
    my $x = 0;
    while (length $r > 0) {
        $x ^= unpack 'I', substr($r, 0, 4, q{});
    }
    return $x;
}

sub rand_32bit;

1;
__END__

=head1 NAME

UUID::Generator::PurePerl::RNG::Bridge - abstract class of RNG bridge

=head1 DESCRIPTION

UUID::Generator::PurePerl::RNG::Bridge is abstract class of RNG bridge interface.

=head1 AUTHOR

ITO Nobuaki E<lt>banb@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
