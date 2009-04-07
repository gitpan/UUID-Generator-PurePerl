use strict;
use warnings;
use Test::More;

eval q{ use Data::UUID };
plan skip_all => "Data::UUID is not installed." if $@;

plan tests => 20;

use Data::UUID;
use UUID::Generator::PurePerl;
use UUID::Object;

my $up = UUID::Generator::PurePerl->new();
my $du = Data::UUID->new();

# in this test script, NameSpace_URL() etc cannot be used.  why?
sub du_const {
    my $name = shift;
    return Data::UUID::constant($name, 0);
}

for (1 .. 10) {
    my $name = random_dns();

    my $uuid0 = lc $du->to_string($du->create_from_name(du_const('NameSpace_DNS'), $name));
    my $uuid1 = lc $up->generate_v3(uuid_ns_dns, $name)->as_string;

    is( $uuid1, $uuid0, 'ns:DNS:' . $name );
}

for (1 .. 10) {
    my $name = random_url();

    my $uuid0 = lc $du->to_string($du->create_from_name(du_const('NameSpace_URL'), $name));
    my $uuid1 = lc $up->generate_v3(uuid_ns_url, $name)->as_string;

    is( $uuid1, $uuid0, 'ns:URL:' . $name );
}

# TODO: OID and X.500 ?

exit;

my $RC;
sub random_chars {
    return $RC if defined $RC;
    $RC = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-.';
    return $RC;
}

sub random_name {
    my ($min, $max) = @_;
    $min = 5 if ! defined $min;
    $max = $min + 10 if ! defined $max;
    my $n = join q{}, map { substr random_chars(), int(rand(64)), 1 } 
                      (0 .. $min + int(rand($max - $min + 1)));

    return $n;
}

sub random_dns {
    my @tlds = qw( com org net );

    return random_name(5, 15) . q{.example.} . $tlds[int rand 3];
}

sub random_url {
    my @path;
    my $m = int rand 5;
    while ($m -- > 0) {
        push @path, random_name(3, 6);
    }

    return 'http://' . random_dns . '/' . join(q{/}, @path);
}

