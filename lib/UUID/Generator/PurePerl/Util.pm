package UUID::Generator::PurePerl::Util;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT = qw( digest_as_octets digest_as_32bit digest_as_16bit );

use Carp;
use Digest;

sub fold_into_octets {
    my ($num_octets, $s) = @_;

    my $x = "\x0" x $num_octets;

    while (length $s > 0) {
        my $n = q{};
        while (length $x > 0) {
            my $c = ord(substr $x, -1, 1, q{}) ^ ord(substr $s, -1, 1, q{});
            $n = chr($c) . $n;
            last if length $s <= 0;
        }
        $n = $x . $n;

        $x = $n;
    }

    return $x;
}

sub digest_as_octets {
    my $num_octets = shift;

    my $d;
    $d = eval { Digest->new('SHA-1') };
    $d = eval { Digest->new('MD5')   }  if $@;
    die if $@;

    $d->add($_) for @_;

    return fold_into_octets($num_octets, $d->digest);
}

sub digest_as_32bit {
    return unpack 'N', digest_as_octets(4, @_);
}

sub digest_as_16bit {
    return unpack 'n', digest_as_octets(2, @_);
}

1;
__END__

=head1 NAME

UUID::Generator::PurePerl::Util - Utility functions for UUID::Generator::PurePerl

=head1 DESCRIPTION

Several functions useful for UUID::Generator::PurePerl internal are here.

Mainly, internal use only.

=head1 AUTHOR

ITO Nobuaki E<lt>banb@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
