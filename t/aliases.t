#!/usr/bin/perl -w
# ----------------------------------------------------------------------
# vim: set ft=perl:
# $Id: aliases.t,v 1.2 2002/09/24 11:04:10 dlc Exp $
# ----------------------------------------------------------------------
# All email addresses in this file go to unresolvable.perl.org, which
# I think I made up.  My apologies to Tom, Barnaby, Bridget, and Quincy
# if you get mail at these addresses. :)
# ----------------------------------------------------------------------

use strict;
use Mail::ExpandAliases;
use Test;

my ($m, @a);
BEGIN {
    plan test => 8;
}

ok(1);

ok(defined($m = Mail::ExpandAliases->new('t/aliases')));

@a = $m->expand('spam');
ok($a[0], '/dev/null');

@a = $m->expand('jones');
ok(join(',', @a), 'Tom_Jones@unresolvable.perl.org,Barnaby_Jones@unresolvable.perl.org,Bridget_Jones@unresolvable.perl.org,Quincy_Jones@unresolvable.perl.org');

@a = $m->expand('MAILER-DAEMON');
ok($a[0], 'postmaster'); 

@a = $m->expand('not-there');
ok($a[0], 'not-there');

@a = $m->expand('tjones');
ok($a[0], 'Tom_Jones@unresolvable.perl.org');

@a = $m->expand("commits");
ok(join(',', @a), 'Tom_Jones@unresolvable.perl.org,Barnaby_Jones@unresolvable.perl.org');
