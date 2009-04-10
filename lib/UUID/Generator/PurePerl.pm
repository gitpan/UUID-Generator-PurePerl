package UUID::Generator::PurePerl;

use strict;
use warnings;
use 5.006;

our $VERSION = '0.03';

use Carp;
use Digest;
use Time::HiRes;
use UUID::Object;
use UUID::Generator::PurePerl::RNG;
use UUID::Generator::PurePerl::NodeID;
use UUID::Generator::PurePerl::Util;

sub new {
    my $class = shift;
    my $self  = bless {}, $class;

    return $self;
}

sub rng {
    my ($self) = @_;

    if (! defined $self->{rng}) {
        $self->{rng} = UUID::Generator::PurePerl::RNG->singleton();
    }

    return $self->{rng};
}

sub node_getter {
    my ($self) = @_;

    if (! defined $self->{node_getter}) {
        $self->{node_getter} = UUID::Generator::PurePerl::NodeID->singleton();
    }

    return $self->{node_getter};
}

sub get_timestamp {
    return Time::HiRes::time();
}

sub get_clk_seq {
    my $self = shift;
    my $node_id = shift;

    my $inc_seq = 0;

    my $ts = $self->get_timestamp();
    if (! defined $self->{last_ts} || $ts <= $self->{last_ts}) {
        $inc_seq ++;
    }
    $self->{last_ts} = $ts;

    if (! defined $self->{last_node}) {
        if (defined $node_id) {
            $inc_seq ++;
        }
    }
    else {
        if (! defined $node_id || $node_id ne $self->{last_node}) {
            $inc_seq ++;
        }
    }
    $self->{last_node} = $node_id;

    if (! defined $self->{clk_seq}) {
        $self->{clk_seq} = $self->_generate_clk_seq();
        return $self->{clk_seq} & 0x03ff;
    }

    if ($inc_seq) {
        $self->{clk_seq} = ($self->{clk_seq} + 1) % 65536;
    }

    return $self->{clk_seq} & 0x03ff;
}

sub _generate_clk_seq {
    my $self = shift;

    my @data;
    push @data, q{}  . $$;
    push @data, q{:} . Time::HiRes::time();

    return digest_as_16bit(@data);
}

sub generate_v1 {
    my $self = shift;

    my $node = $self->node_getter->node_id();
    my $ts   = $self->get_timestamp();

    return
        UUID::Object->create_from_hash({
            variant => 2,
            version => 1,
            node    => $node,
            time    => $ts,
            clk_seq => $self->get_clk_seq($node),
        });
}

sub generate_v1mc {
    my $self = shift;

    my $node = $self->node_getter->random_node_id();
    my $ts   = $self->get_timestamp();

    return
        UUID::Object->create_from_hash({
            variant => 2,
            version => 1,
            node    => $node,
            time    => $ts,
            clk_seq => $self->get_clk_seq(undef),
        });
}

sub generate_v4 {
    my ($self) = @_;

    my $b = q{};
    for (1 .. 4) {
        $b .= pack 'I', $self->rng->rand_32bit;
    }

    my $u = UUID::Object->create_from_binary($b);

    $u->variant(2);
    $u->version(4);

    return $u;
}

sub generate_v3 {
    my ($self, $ns, $data) = @_;

    return $self->_generate_digest(3, 'MD5', $ns, $data);
}

sub generate_v5 {
    my ($self, $ns, $data) = @_;

    return $self->_generate_digest(5, 'SHA-1', $ns, $data);
}

sub _generate_digest {
    my ($self, $version, $digest, $ns, $data) = @_;

    $ns = UUID::Object->new($ns)->as_binary;

    my $dg = Digest->new($digest);

    $dg->reset();

    $dg->add($ns);

    $dg->add($data);

    my $u = UUID::Object->create_from_binary($dg->digest);
    $u->variant(2);
    $u->version($version);

    return $u;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

UUID::Generator::PurePerl - Universally Unique IDentifier (UUID) Generator

=head1 SYNOPSIS

  use UUID::Generator::PurePerl;
  
  $ug = UUID::Generator::PurePerl->new();
  
  $uuid1 = $ug->generate_v1();
  print $uuid1->as_string();          #=>

=head1 DESCRIPTION

UUID::Generator::PurePerl is UUID
(Universally Unique IDentifier; described in RFC 4122) generator class.

=head1 METHODS

Following methods generate a UUID as an instance of L<UUID::Object>.
For information about retrieving some representation
(such as string, Base64 string, etc) from generated UUID,
please refer to <UUID::Object> document.

=head2 $uuidgen->generate_v1()

This method generates a version 1 UUID.

Version 1 UUID is constructed from machine dependent information
(such as MAC address binded with network interface)
and high resolution timestamp,
so in most cases generated UUIDs are guaranted to be unique over world.

But for the same reason, this sort of UUIDs are not suitable for
security-aware softwares.

=head2 $uuidgen->generate_v1mc()

This method generates a version 1 UUID,
where node address is multicast MAC address created randomly.

=head2 $uuidgen->generate_v3($namespace, $name)

This method generates a version 3 UUID.

Version 3 UUID is for unique id of any names belonging to
some sort of namespace.
Generator calculates digest of that namespace and that name,
and uses it as source of UUID.

In version 3, MD5 mechanism is used as digest function.

Module for calcurating MD5 digest
(such as Digest::MD5)
is required to use this method,
but in modern version perl, those modules are included as core module.

=head2 $uuidgen->generate_v4()

This method generates a version 4 UUID.

Version 4 UUID is constructed from random numbers.
UUIDs have variant and version field with fixed values,
so not whole entity (128-bit) is scattered randomly,
only 122 bits are from random numbers.

=head2 $uuidgen->generate_v5($namespace, $name)

This method generates a version 5 UUID.

Algorithm for creating version 5 UUID is quite similar to one of version 3.
The difference is, SHA-1 is used for digest of name on version 5 UUID,
whereas MD5 is used on version 3.

Module for calcurating SHA-1 digest
(such as Digest::SHA)
is required to use this method.

=head1 CONSTANTS

Namespace UUIDs are not defined in this package.
Use L<UUID::Object> instead.

=head1 NOTICE

In RFC 4122, a principle for creating a time-based UUID (version1 UUID)
is described as follows.

=over 2

=item Obtain a system-wide global lock

=item From a system-wide shared stable store, read the UUID generator state (such as timestamp, clock sequence, and node ID).

=item Retrive current timestamp and node ID

=item Generate a UUID

=item Save the state back to the stable storage.

=item Release the global lock

=back

But in this package, system-wide global locking and persistent storage are
not used.
This class only acts on a small world around a process,
so same UUIDs will be genarated on some conditions over processes, over time.
This nature of uniqueness might not be suitable for your application.

In addition, node ID is a not real physical hardware address in current implementation.
In return, pseudo node ID is calculated from system information.
I have a plan to make real node ID retrieval functionality,
but not yet.

=head1 AUTHOR

ITO Nobuaki E<lt>banb@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<UUID::Object>, L<UUID::Generator::PurePerl::Compat>.

RFC 4122: "A Universally Unique IDentifier (UUID) URN Namespace", 2005, L<http://www.ietf.org/rfc/rfc4122.txt>.

=cut
