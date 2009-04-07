package UUID::Generator::PurePerl::RNG::MRMT;

use strict;
use warnings;

use base qw( UUID::Generator::PurePerl::RNG::Bridge );

BEGIN {
    eval q{ use Math::Random::MT };
    if ($@) {
        *enabled = sub { 0 };
    }
    else {
        *enabled = sub { 1 };
    }
}

sub new {
    my $class = shift;
    my $seed  = shift;

    $seed = $class->gen_seed_32bit() if ! defined $seed;

    if ($class->enabled) {
        my $mt = Math::Random::MT->new($seed);
        my $self = \$mt;
        return bless $self, $class;
    }
    else {
        my $u = undef;
        my $self = \$u;
        return bless $self, $class;
    }
}

sub rand_32bit {
    my $self = shift;
    my $mt = $$self;
    return 0 if ! $mt;

    return int($mt->rand() * 65536.0 * 65536);
}

1;
__END__

=head1 NAME

UUID::Generator::PurePerl::RNG::MRMT - RNG bridge of Math::Random::MT

=head1 DESCRIPTION

UUID::Generator::PurePerl::RNG::MRMT is RNG bridge interface of Math::Random::MT.

=head1 AUTHOR

ITO Nobuaki E<lt>banb@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
