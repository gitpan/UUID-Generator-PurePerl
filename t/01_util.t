use strict;
use warnings;
use Test::More tests => 5 * 6;

use UUID::Generator::PurePerl::Util;

for my $len (1 .. 6) {
    for my $i (1 .. 5) {
        my $d = digest_as_octets($len, q{} . rand);

        is( length($d), $len, "digest_as_octets(${len}): trial ${i}" );
    }
}

