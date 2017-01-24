#!/usr/bin/perl
# getpcomidx - fetch www.perl.com's index.html document
use IO::Socket;
$sock = new IO::Socket::INET (PeerAddr => 'www.dropbox.com',
PeerPort => 'http(80)');
die "Couldn't create socket: $@" unless $sock;
# the library doesn't support $! setting; it uses $@

$sock->autoflush(1);

# Mac *must* have \015\012\015\012 instead of \n\n here.
# It's a good idea for others, too, as that's the spec,
# but implementations are encouraged to accept "\cJ\cJ" too,
# and as far as we've seen, they do.
$sock->print("GET /home http/1.1\n\n");
$document = join('', $sock->getlines());
print "DOC IS: $document\n";