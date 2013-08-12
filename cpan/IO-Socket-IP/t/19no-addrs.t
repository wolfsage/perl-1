#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use IO::Socket::IP;
use Socket qw( SOCK_STREAM AF_INET );

# Compatibility test for
# IO::Socket::INET->new( Blocking => 0 ) still creates a defined filehandle

{
   my $sock = IO::Socket::IP->new( Family => AF_INET );

   ok( defined $sock->fileno, '$sock->fileno for Family => AF_INET' );
   is( $sock->sockdomain, AF_INET, '$sock->sockdomain for Family => AF_INET' );
   is( $sock->socktype, SOCK_STREAM, '$sock->socktype for Family => AF_INET' );
}

SKIP: {
   my $AF_INET6 = eval { require Socket and Socket::AF_INET6() } or
      skip "No AF_INET6", 3;

   eval { IO::Socket::IP->new( LocalHost => "::1" ) } or
      skip "Unable to bind to ::1", 3;

   my $sock = IO::Socket::IP->new( Family => $AF_INET6 );

   ok( defined $sock->fileno, '$sock->fileno for Family => AF_INET6' );
   is( $sock->sockdomain, $AF_INET6, '$sock->sockdomain for Family => AF_INET6' );
   is( $sock->socktype, SOCK_STREAM, '$sock->socktype for Family => AF_INET6' );
}

done_testing;
