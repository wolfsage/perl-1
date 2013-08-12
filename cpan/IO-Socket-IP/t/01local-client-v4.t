#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use IO::Socket::IP;

use IO::Socket::INET;
use Socket qw( unpack_sockaddr_in );

foreach my $socktype (qw( SOCK_STREAM SOCK_DGRAM )) {
   my $testserver = IO::Socket::INET->new(
      ( $socktype eq "SOCK_STREAM" ? ( Listen => 1 ) : () ),
      LocalHost => "127.0.0.1",
      Type      => Socket->$socktype,
      Proto     => ( $socktype eq "SOCK_STREAM" ? "tcp" : "udp" ), # Because IO::Socket::INET is stupid and always presumes tcp
   ) or die "Cannot listen on PF_INET - $@";

   my $socket = IO::Socket::IP->new(
      PeerHost    => "127.0.0.1",
      PeerService => $testserver->sockport,
      Type        => Socket->$socktype,
   );

   ok( defined $socket, "IO::Socket::IP->new constructs a $socktype socket" ) or
      diag( "  error was $@" );

   is( $socket->sockdomain, AF_INET,           "\$socket->sockdomain for $socktype" );
   is( $socket->socktype,   Socket->$socktype, "\$socket->socktype for $socktype" );

   my $testclient = ( $socktype eq "SOCK_STREAM" ) ? 
      $testserver->accept : 
      do { $testserver->connect( $socket->sockname ); $testserver };

   ok( defined $testclient, "accepted test $socktype client" );

   ok( $socket->connected, "\$socket is connected for $socktype" );

   is_deeply( [ unpack_sockaddr_in $socket->sockname ],
              [ unpack_sockaddr_in $testclient->peername ],
              "\$socket->sockname for $socktype" );

   is_deeply( [ unpack_sockaddr_in $socket->peername ],
              [ unpack_sockaddr_in $testclient->sockname ],
              "\$socket->peername for $socktype" );

   is( $socket->peerhost, "127.0.0.1",           "\$socket->peerhost for $socktype" );
   is( $socket->peerport, $testserver->sockport, "\$socket->peerport for $socktype" );

   # Unpack just so it pretty prints without wrecking the terminal if it fails
   is( unpack("H*", $socket->sockaddr), "7f000001", "\$socket->sockaddr for $socktype" );
   is( unpack("H*", $socket->peeraddr), "7f000001", "\$socket->peeraddr for $socktype" );

   # Can't easily test the non-numeric versions without relying on the system's
   # ability to resolve the name "localhost"

   $socket->close;
   ok( !$socket->connected, "\$socket not connected after close for $socktype" );
}

done_testing;
