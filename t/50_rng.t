use strict;
use warnings;
use Test::More tests => 1;

use UUID::Generator::PurePerl::RNG;

my $g = UUID::Generator::PurePerl::RNG->new();
my $x = 0;
for (1 .. 10) {
    my $r = $g->rand_32bit;
    $x |= $r;
}
# $x will be 0 in 1e-100 probability

ok( $x != 0, 'random data' );
