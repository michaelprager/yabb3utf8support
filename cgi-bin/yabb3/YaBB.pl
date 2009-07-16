#!/usr/bin/perl --
use strict;
# this should be fun

###############################################################################
# YaBB.pl                                                                     #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 2.4                                                    #
# Packaged:       April 12, 2009                                              #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com            #
#               Your source for web hosting, web design, and domains.         #
###############################################################################
#
# $Id$

### Version Info ###
(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;

use CGI::Carp qw(fatalsToBrowser); # used only for tests

BEGIN {
	# Make sure the module path is present
	push(@INC, "./Modules");

	if (defined $ENV{'SERVER_SOFTWARE'} and $ENV{'SERVER_SOFTWARE'} =~ /IIS/) {
		$GLOBAL::IIS = 1;
		$0 =~ m~(.*)(\\|/)~;
        my $path = $1;
		$path =~ s~\\~/~g;
		chdir($path);
		push(@INC, $path);
	}

	# Modify the following line if your forum main scriptname must be different.
	# The default is: "YaBB". Do this also in AdminIndex.pl!!!
	# Don't forget to modify also all index.html files in the folders!!!
	$GLOBAL::EXEC = "YaBB";

	my $script_root = $ENV{'SCRIPT_FILENAME'};
    $script_root = defined $script_root ? $script_root : "" ;
	$script_root =~ s/\/$GLOBAL::EXEC\.(pl|cgi)//ig;

    use YaBB3::Paths qw(:all); #exporting variables naughty
	require "$vardir/Settings.pl"; #TODO: lots of work on Settings.pl

	# If we're debugging, try to use HiRes time.
    if ($GLOBAL::DEBUG) {
        eval { require Time::HiRes; import Time::HiRes qw(time); };
    }
	our $START_TIME = time();

	require "$sourcedir/Subs.pl";
	require "$sourcedir/System.pl";
    use YaBB3::DateTime qw(:all);
	require "$sourcedir/Load.pl";

	require "$sourcedir/Guardian.pl";
	require "$boardsdir/forum.master";

    sub warn {
        open my $log, ">>", "ERROR.LOG" or die "Could not open logfile. $@";
        print $log, @_;
        close $log;
    }
} # END of BEGIN block

no strict; # I can only do so much in a day...

# If enabled: check if hard drive has enough space to safely operate the board
my $hostchecked = &freespace;

# Auto Maintenance Hook
$maintenance = 2 if !$maintenance && -e "$vardir/maintenance.lock";

&LoadCookie;       # Load the user's cookie (or set to guest)
&LoadUserSettings; # Load user settings
&WhatTemplate;     # Figure out which template to be using.
&WhatLanguage;     # Figure out which language file we should be using! :D

# Do this now that language is available
$yyfreespace = $hostchecked < 0 ? $error_txt{'module_missing'} : (($yyfreespace && (($debug == 1 && !$iamguest) || ($debug == 2 && $iamgmod) || $iamadmin)) ? qq~<div>~ . ($hostchecked > 0 ? $maintxt{'freeuserspace'} : $maintxt{'freediskspace'}) . qq~ $yyfreespace</div>~ : '');

if (-e "$vardir/gmodsettings.txt" && $iamgmod) { require "$vardir/gmodsettings.txt"; }
if (!$masterkey) {
	if ($iamadmin || ($iamgmod && $allow_gmod_admin eq 'on' && $gmod_access{"newsettings\;page\=security"} eq 'on')) {
		$yyadmin_alert = $reg_txt{'no_masterkey'};
	}
	$masterkey = $mbname;
}

$formsession = &cloak("$mbname$username");

# check for valid form sessionid in any POST request
if ($ENV{REQUEST_METHOD} =~ /post/i) {
	if ($CGI_query && $CGI_query->cgi_error()) { &fatal_error("denial_of_service", $CGI_query->cgi_error()); }
	if (&decloak($FORM{'formsession'}) ne "$mbname$username") {
		&fatal_error("logged_in_already",$username) if $GLOBAL::ACTION  eq 'login2' && $username ne 'Guest';
		&fatal_error("form_spoofing",$user_ip);
	}
}

if ($is_perm && $accept_permalink) {
	&fatal_error("no_topic_found","$permtitle|C:$permachecktime|T:$threadpermatime") if $permtopicfound == 0;
	&fatal_error("no_board_found","$permboard|C:$permachecktime|T:$threadpermatime") if $permboardfound == 0;
}

&guard;

# Check if the action is allowed from an external domain
if ($referersecurity) { &referer_check; }

if ($regtype == 1 || $regtype == 2) {
	if (-s "$memberdir/memberlist.inactive" > 2) {
		&RegApprovalCheck; &activation_check;
	} elsif (-s "$memberdir/memberlist.approve" > 2) {
		&RegApprovalCheck;
	}
}

require "$sourcedir/Security.pl";

&banning;  # Check for banned people
&LoadIMs;  # Load IM's
&WriteLog; # write into the logfile

$SIG{__WARN__} = sub { &fatal_error("error_occurred","@_"); };
eval { &yymain; };
if ($@) { &fatal_error("untrapped",":<br />$@"); }

sub yymain {
	# Choose what to do based on the form action
	if ($maintenance) {
		if    ($GLOBAL::ACTION  eq 'login2')    { require "$sourcedir/LogInOut.pl"; &Login2; }
		# Allow password reminders in case admins forgets their admin password
		elsif ($GLOBAL::ACTION  eq 'reminder')  { require "$sourcedir/LogInOut.pl"; &Reminder; }
		elsif ($GLOBAL::ACTION  eq 'validate')  { require "$sourcedir/Decoder.pl"; &convert; }
		elsif ($GLOBAL::ACTION  eq 'reminder2') { require "$sourcedir/LogInOut.pl"; &Reminder2; }
		elsif ($GLOBAL::ACTION  eq 'resetpass') { require "$sourcedir/LogInOut.pl"; &Reminder3; }

		if (!$iamadmin) { require "$sourcedir/LogInOut.pl"; &InMaintenance; }
	}

	# Guest can do the very few following actions
	&KickGuest if $iamguest && !$guestaccess && $GLOBAL::ACTION  !~ /^(login|register|reminder|validate|activate|resetpass|guestpm|checkavail|$randaction)2?$/;

	if ($GLOBAL::ACTION  ne "") {
		if ($GLOBAL::ACTION  eq $randaction) {
			require "$sourcedir/Decoder.pl"; &convert;
		} else {
			require "$sourcedir/SubList.pl";
			if ($director{$GLOBAL::ACTION }) {
				my @act = split(/&/, $director{$GLOBAL::ACTION });
				require "$sourcedir/$act[0]";
				&{$act[1]};
			} else {
				require "$sourcedir/BoardIndex.pl";
				&BoardIndex;
			}
		}
	} elsif ($INFO{'num'} ne "") {
		require "$sourcedir/Display.pl";
		&Display;
	} elsif ($currentboard eq "") {
		require "$sourcedir/BoardIndex.pl";
		&BoardIndex;
	} else {
		require "$sourcedir/MessageIndex.pl";
		&MessageIndex;
	}
}

# Those who write software only for pay should go hurt some other field.
# - Erik Naggum

1;
