use strict;
use warnings;
use Test::More tests => 1;

use UUID::Generator::PurePerl;

my $g = UUID::Generator::PurePerl->new();

my $u1 = $g->generate_v1();
my $u2 = $g->generate_v1();

ok( $u1 != $u2, 'UUIDs differ' );

# TODO: write more test
