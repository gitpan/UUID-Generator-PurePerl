use strict;
use warnings;
use Test::More;

use UUID::Generator::PurePerl::RNG::MRMTPP;
our $RNG = 'UUID::Generator::PurePerl::RNG::MRMTPP';

plan skip_all => "${RNG} is not enabled." if ! $RNG->enabled;

plan tests => 1;

my $g = $RNG->new();
my $x = 0;
for (1 .. 10) {
    my $r = $g->rand_32bit;
    $x |= $r;
}
# $x will be 0 in 1e-100 probability

ok( $x != 0, 'random data' );
