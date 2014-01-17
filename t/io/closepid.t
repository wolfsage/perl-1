#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

if ($^O eq 'dos') {
    skip_all("no multitasking");
}

plan tests => 3;
watchdog(10, $^O eq 'MSWin32' ? "alarm" : '');

use Config;
$| = 1;
$SIG{PIPE} = 'IGNORE';
$SIG{TERM} = 'IGNORE' if $^O eq 'interix';

my $perl = which_perl();
$perl .= qq[ "-I../lib"];

my $killsig = 'TERM';
$killsig = 15 unless $Config{sig_name} =~ /\bTERM\b/;

SKIP:
{
    skip("Not relevant to $^O", 3)
      if $^O eq "MSWin32" || $^O eq "VMS";
    skip("only matters for waitpid or wait4", 3)
      unless $Config{d_waitpid} || $Config{d_wait4};
    # [perl #119893]
    # close on the original of a popen handle dupped to a standard handle
    # would wait4pid(0, ...)
    open my $savein, "<&", \*STDIN;
    my $pid = open my $fh1, qq/$perl -e "sleep 50" |/;
    ok($pid, "open a pipe");
    # at this point PL_fdpids[fileno($fh1)] is the pid of the new process
    ok(open(STDIN, "<&=", $fh1), "dup the pipe");
    # now PL_fdpids[fileno($fh1)] is zero and PL_fdpids[0] is
    # the pid of the process created above, previously this would block
    # internally on waitpid(0, ...)
    ok(close($fh1), "close the original");
    kill $killsig, $pid;
    open STDIN, "<&", $savein;
}
