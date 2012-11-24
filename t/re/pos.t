#!./perl

# Make sure pos / resetting pos on failed match works

use strict;
use warnings;

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

plan tests => 4;

# With a var
{
	my $str = "bird";

	$str =~ /i/g;

	is(pos($str),  2, 'pos correct');

	$str =~ /toolongtomatch/g;

	is(pos($str), undef, 'pos undef after failed match');
}

# With $_
{
	$_ = "bird";

	m/i/g;

	is(pos, 2, 'pos correct');

	m/toolongtomatch/g;

	is(pos, undef, 'pos undef after failed match');
}
