#!/usr/bin/perl -w --
use strict;

use TAP::Harness;

my $harness = TAP::Harness->new({ });

$harness->runtests(
    't/01dbtest.t',
);
