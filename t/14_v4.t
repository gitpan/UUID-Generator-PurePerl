use strict;
use warnings;
use Test::More tests => 3*5;

use UUID::Generator::PurePerl;

my $g = UUID::Generator::PurePerl->new();

for (1 .. 5) {

my $uuid = $g->generate_v4();

ok( $uuid->as_string =~ m{ \A [0-9a-f]{8} (?: - [0-9a-f]{4} ){3} - [0-9a-f]{12} \z }ixmso, 'format' );

is( $uuid->variant, 2, 'variant = 2' );
is( $uuid->version, 4, 'version = 4' );

#diag $uuid;

}
