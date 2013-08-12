#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use IO::Socket::IP;

use Socket qw( SOL_SOCKET SO_REUSEADDR SO_REUSEPORT SO_BROADCAST );

TODO: {
   local $TODO = "SO_REUSEADDR doesn't appear to work on cygwin smokers" if $^O eq "cygwin";
   # I honestly have no idea why this fails, and people don't seem to be able
   # to reproduce it on a development box. I'll mark it TODO for now until we
   # can gain any more insight into it.

   my $sock = IO::Socket::IP->new(
      LocalHost => "127.0.0.1",
      Type      => SOCK_STREAM,
      Listen    => 1,
      ReuseAddr => 1,
   ) or die "Cannot socket() - $@";

   ok( $sock->getsockopt( SOL_SOCKET, SO_REUSEADDR ), 'SO_REUSEADDR set' );
}

SKIP: {
   # Some OSes don't implement SO_REUSEPORT
   skip "No SO_REUSEPORT", 1 unless defined eval { SO_REUSEPORT };

   my $sock = IO::Socket::IP->new(
      LocalHost => "127.0.0.1",
      Type      => SOCK_STREAM,
      Listen    => 1,
      ReusePort => 1,
   ) or die "Cannot socket() - $@";

   ok( $sock->getsockopt( SOL_SOCKET, SO_REUSEPORT ), 'SO_REUSEPORT set' );
}

{
   my $sock = IO::Socket::IP->new(
      LocalHost => "127.0.0.1",
      Type      => SOCK_DGRAM,
      Broadcast => 1,
   ) or die "Cannot socket() - $@";

   ok( $sock->getsockopt( SOL_SOCKET, SO_BROADCAST ), 'SO_BROADCAST set' );
}

done_testing;
