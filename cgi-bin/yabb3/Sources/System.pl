###############################################################################
# System.pl                                                                   #
###############################################################################
# YaBB: Yet another Bulletin Board                                            #
# Open-Source Community Software for Webmasters                               #
# Version:        YaBB 3.0 Beta                                               #
# Packaged:       October 05, 2010                                            #
# Distributed by: http://www.yabbforum.com                                    #
# =========================================================================== #
# Copyright (c) 2000-2010 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team                                     #
#               with assistance from the YaBB community.                      #
###############################################################################

$systemplver = 'YaBB 3.0 Beta $Revision: 100 $';

sub BoardTotals {
	my ($testboard, $line, @lines, $updateboard, @boardvars, $tag, $cnt);
	my ($job, @updateboards) = @_;
	if (!@updateboards) { @updateboards = @allboards; }
	chomp(@updateboards);
	if (@updateboards) {
		my @tags = qw(board threadcount messagecount lastposttime lastposter lastpostid lastreply lastsubject lasticon lasttopicstate);
		if ($job eq "load") {
			fopen(FORUMTOTALS, "$boardsdir/forum.totals") || &fatal_error('cannot_open', "$boardsdir/forum.totals", 1);
			@lines = <FORUMTOTALS>;
			fclose(FORUMTOTALS);
			chomp(@lines);
			foreach $updateboard (@updateboards) {
				foreach $line (@lines) {
					@boardvars = split(/\|/, $line);
					if ($boardvars[0] eq $updateboard && exists($board{ $boardvars[0] })) {
						for ($cnt = 1; $cnt < @tags; $cnt++) {
							${$uid.$updateboard}{ $tags[$cnt] } = $boardvars[$cnt];
						}
						last;
					}
				}
			}

		} elsif ($job eq "update") {
			fopen(FORUMTOTALS, "+<$boardsdir/forum.totals") || &fatal_error('cannot_open', "$boardsdir/forum.totals", 1);
			@lines = <FORUMTOTALS>;
			for ($line = 0; $line < @lines; $line++) {
				@boardvars = split(/\|/, $lines[$line]);
				if (exists $board{ $boardvars[0] }) {
					if ($boardvars[0] eq $updateboards[0]) {
						$lines[$line] = "$updateboards[0]|";
						chomp $boardvars[9];
						for ($cnt = 1; $cnt < @tags; $cnt++) {
							if (exists(${$uid.$boardvars[0]}{ $tags[$cnt] })) {
								$lines[$line] .= ${$uid.$boardvars[0]}{ $tags[$cnt] };
							} else {
								$lines[$line] .= $boardvars[$cnt];
							}
							$lines[$line] .= $cnt < $#tags ? "|" : "\n";
						}
					}
				} else {
					$lines[$line] = '';
				}
			}
			truncate FORUMTOTALS, 0;
			seek FORUMTOTALS, 0, 0;
			print FORUMTOTALS @lines;
			fclose(FORUMTOTALS);

		} elsif ($job eq "delete") {
			fopen(FORUMTOTALS, "+<$boardsdir/forum.totals") || &fatal_error('cannot_open', "$boardsdir/forum.totasl", 1);
			@lines = <FORUMTOTALS>;
			for ($line = 0; $line < @lines; $line++) {
				@boardvars = split(/\|/, $lines[$line], 2);
				if ($boardvars[0] eq $updateboards[0] || !exists $board{$boardvars[0]}) {
					$lines[$line] = '';
				}
			}
			truncate FORUMTOTALS, 0;
			seek FORUMTOTALS, 0, 0;
			print FORUMTOTALS @lines;
			fclose(FORUMTOTALS);

		} elsif ($job eq "add") {
			fopen(FORUMTOTALS, ">>$boardsdir/forum.totals") || &fatal_error('cannot_open', "$boardsdir/forum.totals", 1);
			foreach (@updateboards) { print FORUMTOTALS "$_|0|0|N/A|N/A||||\n"; }
			fclose(FORUMTOTALS);
		}
	}
}

sub BoardCountTotals {
	my $cntboard = $_[0];
	unless ($cntboard) { return undef; }
	my (@threads, $threadcount, $messagecount, $i, $threadline);

	fopen(BOARD, "$boardsdir/$cntboard.txt") || &fatal_error('cannot_open', "$boardsdir/$cntboard.txt", 1);
	@threads = <BOARD>;
	fclose(BOARD);
	$threadcount  = @threads;
	$messagecount = $threadcount;
	for ($i = 0; $i < @threads; $i++) {
		@threadline = split(/\|/, $threads[$i]);
		if ($threadline[8] =~ /m/) {
			$threadcount--;
			$messagecount--;
			next;
		}
		$messagecount += $threadline[5];
	}
	${$uid.$cntboard}{'threadcount'}  = $threadcount;
	${$uid.$cntboard}{'messagecount'} = $messagecount;
	&BoardSetLastInfo($cntboard,\@threads);
}

sub BoardSetLastInfo {
	my ($setboard,$board_ref) = @_;
	my ($lastthread, $lastthreadid, $lastthreadstate, @lastthreadmessages, @lastmessage);

	foreach $lastthread (@$board_ref) {
		if ($lastthread) {
			($lastthreadid, undef, undef, undef, undef, undef, undef, undef, $lastthreadstate) = split(/\|/, $lastthread);
			if ($lastthreadstate !~ /m/) {
				chomp $lastthreadstate;
				fopen(FILE, "$datadir/$lastthreadid.txt") || &fatal_error("cannot_open","$datadir/$lastthreadid.txt", 1);
				@lastthreadmessages = <FILE>;
				fclose(FILE);
				@lastmessage = split(/\|/, $lastthreadmessages[$#lastthreadmessages], 7);
				last;
			}
			$lastthreadid = '';
		}
	}
	${$uid.$setboard}{'lastposttime'}   = $lastthreadid ? $lastmessage[3]      : 'N/A';
	${$uid.$setboard}{'lastposter'}     = $lastthreadid ? ($lastmessage[4] eq "Guest" ? "Guest-$lastmessage[1]" : $lastmessage[4]) : 'N/A';
	${$uid.$setboard}{'lastpostid'}     = $lastthreadid ? $lastthreadid        : '';
	${$uid.$setboard}{'lastreply'}      = $lastthreadid ? $#lastthreadmessages : '';
	${$uid.$setboard}{'lastsubject'}    = $lastthreadid ? $lastmessage[0]      : '';
	${$uid.$setboard}{'lasticon'}       = $lastthreadid ? $lastmessage[5]      : '';
	${$uid.$setboard}{'lasttopicstate'} = ($lastthreadid && $lastthreadstate) ? $lastthreadstate : "0";
	&BoardTotals("update", $setboard);
}

#### THREAD MANAGEMENT ####

sub MessageTotals {
	# usage: &MessageTotals("task",<threadid>)
	# tasks: update, load, incview, incpost, decpost, recover
	my ($job,$updatethread) = @_;
	chomp $updatethread;
	return if !$updatethread;

	if ($job eq "update") {
		if (${$updatethread}{'board'} eq "") { ## load if the variable is not already filled
			&MessageTotals("load",$updatethread);
		}

	} elsif ($job eq "load") {
		if (${$updatethread}{'board'} ne "") { return; } ## skip load if the variable is already filled
		fopen(CTB, "$datadir/$updatethread.ctb",1);
		foreach (<CTB>) {
			if ($_ =~ /^'(.*?)',"(.*?)"/) { ${$updatethread}{$1} = $2; }
		}
		fclose(CTB);
		@repliers = split(",", ${$updatethread}{'repliers'});
		return;

	} elsif ($job eq "incview") {
		${$updatethread}{'views'}++;

	} elsif ($job eq "incpost") {
		${$updatethread}{'replies'}++;

	} elsif ($job eq "decpost") {
		${$updatethread}{'replies'}--;

	} elsif ($job eq 'recover') {
		# storing thread status
		my $threadstatus;
		my $openboard = ${$updatethread}{'board'};
		fopen(TESTBOARD, "$boardsdir/$openboard.txt") || &fatal_error('cannot_open', "$boardsdir/$openboard.txt", 1);
		while ($ThreadLine = <TESTBOARD>) {
			if ($updatethread == (split /\|/, $ThreadLine, 2)[0]) {
				$threadstatus = (split /\|/, $ThreadLine)[8];
				chomp $threadstatus;
				last;
			}
		}
		fclose(TESTBOARD);
		# storing thread other info
		fopen(MSG, "$datadir/$updatethread.txt") || &fatal_error('cannot_open', "$datadir/$updatethread.txt", 1);
		my @threaddata = <MSG>;
		fclose(MSG);
		my @lastinfo = split(/\|/, $threaddata[$#threaddata]);
		my $lastpostdate = sprintf("%010d", $lastinfo[3]);
		my $lastposter = $lastinfo[4] eq 'Guest' ? qq~Guest-$lastinfo[1]~ : $lastinfo[4];
		# rewrite/create a correct thread.ctb
		${$updatethread}{'replies'} = $#threaddata;
		${$updatethread}{'views'} = ${$updatethread}{'views'} || 0;
		${$updatethread}{'lastposter'} = $lastposter;
		${$updatethread}{'lastpostdate'} = $lastpostdate;
		${$updatethread}{'threadstatus'} = $threadstatus;
		@repliers = ();

	} else {
		return;
	}

	## trap writing false ctb files on forged num= actions ##
	if (-e "$datadir/$updatethread.txt") {
		my $format = 'SDT, DD MM YYYY HH:mm:ss zzz'; # The format
		# Save their old format
		my $timeformat = ${$uid.$username}{'timeformat'};
		my $timeselect = ${$uid.$username}{'timeselect'};
		# Override their settings
		${$uid.$username}{'timeformat'} = $format;
		${$uid.$username}{'timeselect'} = 7;
		# Do the work
		my $newtime = &timeformat($date, 1,"rfc");
		# And restore their settings
		${$uid.$username}{'timeformat'} = $timeformat;
		${$uid.$username}{'timeselect'} = $timeselect;

		${$updatethread}{'repliers'} = join(",", @repliers);

		# Changes here on @tag must also be done in Post.pl -> sub Post2 -> my @tag = ...
		my @tag = qw(board replies views lastposter lastpostdate threadstatus repliers);
		fopen(UPDATE_CTB, ">$datadir/$updatethread.ctb",1) || &fatal_error('cannot_open', "$datadir/$updatethread.ctb", 1);
		print UPDATE_CTB qq~### ThreadID: $updatethread, LastModified: $newtime ###\n\n~;
		for (my $cnt = 0; $cnt < @tag; $cnt++) {
			print UPDATE_CTB qq~'$tag[$cnt]',"${$updatethread}{$tag[$cnt]}"\n~;
		}
		fclose(UPDATE_CTB);
	}
}

# NOBODY expects the Spanish Inquisition!
# - Monty Python

#### USER AND MEMBERSHIP MANAGEMENT ####

sub UserAccount {
	my ($user, $action, $pars) = @_;
	return if !${$uid.$user}{'password'};

	if ($action eq "update") {
		if ($pars) {
			foreach (split(/\+/, $pars)) { ${$uid.$user}{$_} = $date; }
		} elsif ($username eq $user) {
			${$uid.$user}{'lastonline'} = $date;
		}
		$userext = "vars";
		${$uid.$user}{'reversetopic'} = $ttsreverse unless exists(${$uid.$user}{'reversetopic'});
	} elsif ($action eq "preregister") {
		$userext = "pre";
	} elsif ($action eq "register") {
		$userext = "vars";
	} elsif ($action eq "delete") {
		unlink "$memberdir/$user.vars";
		return;
	} else { $userext = "vars"; }

	# using sequential tag writing as hashes do not sort the way we like them to
	my @tags = qw(realname password position addgroups email hidemail regdate regtime regreason location bday gender userpic usertext signature template language stealth webtitle weburl icq aim yim skype myspace facebook msn gtalk timeselect timeformat timeoffset dsttimeoffset dynamic_clock postcount lastonline lastpost lastim im_ignorelist im_popup im_imspop pmmessprev pmviewMess pmactprev notify_me board_notifications thread_notifications favorites buddylist cathide pageindex reversetopic postlayout sesquest sesanswer session lastips onlinealert offlinestatus awaysubj awayreply awayreplysent spamcount spamtime numberformat);
	if ($extendedprofiles) {
		require "$sourcedir/ExtendedProfiles.pl";
		push(@tags, &ext_get_fields_array());
	}
	fopen(UPDATEUSER, ">$memberdir/$user.$userext",1) || &fatal_error('cannot_open', "$memberdir/$user.$userext", 1);
	print UPDATEUSER "### User variables for ID: $user ###\n\n";
	for (my $cnt = 0; $cnt < @tags; $cnt++) {
		print UPDATEUSER qq~'$tags[$cnt]',"${$uid.$user}{$tags[$cnt]}"\n~;
	}
	fclose(UPDATEUSER);
}

sub MemberIndex {
	my ($memaction, $user) = @_;
	if ($memaction eq "add" && &LoadUser($user)) {
		$theregdate = &stringtotime(${$uid.$user}{'regdate'});
		$theregdate = sprintf("%010d", $theregdate);
		if (!${$uid.$user}{'postcount'}) { ${$uid.$user}{'postcount'} = 0; }
		if (!${$uid.$user}{'position'})  { ${$uid.$user}{'position'}  = &MemberPostGroup(${$uid.$user}{'postcount'}); }
		&ManageMemberlist("add", $user, $theregdate);
		&ManageMemberinfo("add", $user, ${$uid.$user}{'realname'}, ${$uid.$user}{'email'}, ${$uid.$user}{'position'}, ${$uid.$user}{'postcount'});

		fopen(TTL, "$memberdir/members.ttl") || &fatal_error('cannot_open', "$memberdir/members.ttl", 1);
		$buffer = <TTL>;
		fclose(TTL);

		($membershiptotal, undef) = split(/\|/, $buffer);
		$membershiptotal++;

		fopen(TTL, ">$memberdir/members.ttl") || &fatal_error('cannot_open', "$memberdir/members.ttl", 1);
		print TTL qq~$membershiptotal|$user~;
		fclose(TTL);
		return 0;

	} elsif ($memaction eq "remove" && $user) {
		&ManageMemberlist("delete", $user);
		&ManageMemberinfo("delete", $user);

		require "$sourcedir/Notify.pl";
		&removeNotifications($user);

		fopen(MEMLIST, "$memberdir/memberlist.txt") || &fatal_error('cannot_open', "$memberdir/memberlist.txt", 1);
		@memberlt = <MEMLIST>;
		fclose(MEMLIST);

		my $membershiptotal = @memberlt;
		my ($lastuser, undef) = split(/\t/, $memberlt[$#memberlt], 2);

		fopen(TTL, ">$memberdir/members.ttl") || &fatal_error('cannot_open', "$memberdir/members.ttl", 1);
		print TTL qq~$membershiptotal|$lastuser~;
		fclose(TTL);
		return 0;

	} elsif ($memaction eq "check_exist" && $user) {
		&ManageMemberinfo("load");
		while (($curmemb, $value) = each(%memberinf)) {
			($curname, $curmail, $curposition, $curpostcnt) = split(/\|/, $value);
			if    (lc $user eq lc $curmemb) { undef %memberinf; return $curmemb; }
			elsif (lc $user eq lc $curmail) { undef %memberinf; return $curmail; }
			elsif (lc $user eq lc $curname) { undef %memberinf; return $curname; }
		}

	} elsif ($memaction eq "who_is" && $user) {
		&ManageMemberinfo("load");
		while (($curmemb, $value) = each(%memberinf)) {
			($curname, $curmail, $curposition, $curpostcnt) = split(/\|/, $value);
			if    (lc $user eq lc $curmemb) { undef %memberinf; return $curmemb; }
			if    (lc $user eq lc $curmail) { undef %memberinf; return $curmemb; }
			elsif (lc $user eq lc $curname) { undef %memberinf; return $curmemb; }
		}
	}
	# if ($memaction eq "rebuild") { ... Deleted! Don't rebuild
	# member list here, or you run into browser/server timeout
	# with xx-large forums!!! Use Admin.pl -> sub RebuildMemList instead!
}

sub MemberPostGroup {
	$userpostcnt = $_[0];
	$grtitle     = "";
	foreach $postamount (sort { $b <=> $a } keys %Post) {
		if ($userpostcnt >= $postamount) {
			($grtitle, undef) = split(/\|/, $Post{$postamount}, 2);
			last;
		}
	}
	return $grtitle;
}

sub MembershipCountTotal {
	fopen(MEMBERLISTREAD, "$memberdir/memberlist.txt") || &fatal_error('cannot_open', "$memberdir/memberlist.txt", 1);
	my @num = <MEMBERLISTREAD>;
	fclose(MEMBERLISTREAD);
	($latestmember, $meminfo) = split(/\t/, $num[$#num]);
	my $membertotal = @num;
	undef @num;

	fopen(MEMTTL, ">$memberdir/members.ttl") || &fatal_error('cannot_open', "$memberdir/members.ttl", 1);
	print MEMTTL qq~$membertotal|$latestmember~;
	fclose(MEMTTL);

	if (wantarray()) {
		&ManageMemberinfo("load");
		($latestrealname, undef) = split(/\|/, $memberinf{$latestmember}, 2);
		undef %memberinf;
		return ($membertotal, $latestmember, $latestrealname);
	} else {
		return $membertotal;
	}
}

sub RegApprovalCheck {
	## alert admins and gmods of waiting users for approval
	if ($regtype == 1 && ($iamadmin || ($iamgmod && $allow_gmod_admin eq "on" && $gmod_access{'view_reglog'} eq "on"))) {
		opendir(MEM,"$memberdir"); 
		my @approval = (grep /.wait$/i, readdir(MEM));
		closedir(MEM);
		my $app_waiting = $#approval+1;
		if ($app_waiting == 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_one'} $app_waiting $reg_txt{'admin_alert_one'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_end'}</a></div>~;
		} elsif ($app_waiting > 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_more'} $app_waiting $reg_txt{'admin_alert_more'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_end_more'}</a></div>~;
		}
	}
	## alert admins and gmods of waiting users for validations
	if (($regtype == 1 || $regtype == 2) && ($iamadmin || ($iamgmod && $allow_gmod_admin eq "on" && $gmod_access{'view_reglog'} eq "on"))) {
		opendir(MEM,"$memberdir"); 
		my @preregged = (grep /.pre$/i, readdir(MEM));
		closedir(MEM);
		my $preregged_waiting = $#preregged+1;
		if ($preregged_waiting == 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_one'} $preregged_waiting $reg_txt{'admin_alert_act_one'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_act_end'}</a></div>~;
		} elsif ($preregged_waiting > 1) {
			$yyadmin_alert .= qq~<div class="editbg">$reg_txt{'admin_alert_start_more'} $preregged_waiting $reg_txt{'admin_alert_act_more'} <a href="$boardurl/AdminIndex.$yyaext?action=view_reglog">$reg_txt{'admin_alert_act_end_more'}</a></div>~;
		}
	}
}

sub activation_check {
	my ($changed,$regtime,$regmember);
	my $timespan = $preregspan * 3600;
	fopen(INACT, "$memberdir/memberlist.inactive");
	my @actlist = <INACT>;
	fclose(INACT);

	# check if user is in pre-registration and check activation key
	foreach (@actlist) {
		($regtime, undef, $regmember, undef) = split(/\|/, $_, 4);
		if ($date - $regtime > $timespan) {
			$changed = 1;
			unlink "$memberdir/$regmember.pre";

			# add entry to registration log
			fopen(REGLOG, ">>$vardir/registration.log", 1);
			print REGLOG "$date|T|$regmember|\n";
			fclose(REGLOG);
		} else {
			# update non activate user list
			# write valid registration to the list again
			push(@outlist, $_);
		}
	}
	if ($changed) {
		# re-open inactive list for update if changed
		fopen(INACT, ">$memberdir/memberlist.inactive", 1);
		print INACT @outlist;
		fclose(INACT);
	}
}

sub MakeStealthURL {
	# Usage is simple - just call MakeStealthURL with any url, and it will stealthify it.
	# if stealth urls are turned off, it just gives you the same value back
	my $theurl = $_[0];
	if ($stealthurl) {
		$theurl =~ s~([^\w\"\=\[\]]|[\n\b]|\A)\\*(\w+://[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~$boardurl/$yyexec.$yyext?action=dereferer;url=$2~isg;
		$theurl =~ s~([^\"\=\[\]/\:\.(\://\w+)]|[\n\b]|\A)\\*(www\.[^\.][\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+\.[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\;\:\$\-\+\!\*\?/\=\&\@\#\%])~$boardurl/$yyexec.$yyext?action=dereferer;url=http://$2~isg;
	}
	$theurl;
}

sub arraysort {
	# usage: &arraysort(1,"|","R",@array_to_sort);

	my ($sortfield, $delimiter, $reverse, @in) = @_;
	my (@sk, @out, @sortkey, %newline, $oldline, $n);
	foreach $oldline (@in) {
		@sk = split(/$delimiter/, $oldline);
		$sk[$sortfield] = "$sk[$sortfield]-$n";    ## make sure that identical keys are avoided ##
		$n++;
		$newline{ $sk[$sortfield] } = $oldline;
	}
	@sortkey = sort keys %newline;
	if ($reverse) {
		@sortkey = reverse @sortkey;
	}
	foreach (@sortkey) {
		push(@out, $newline{$_});
	}
	return @out;
}

sub keygen {
	## length = output length, type = A (All), U (Uppercase), L (lowercase) ##
	my ($length, $type) = @_;
	if ($length <= 0 || $length > 10000 || !$length) { return; }
	$type = uc($type);
	if ($type ne "A" && $type ne "U" && $type ne "L") { $type = "A"; }

	# generate random ID for password reset or other purposes.
	@chararray = qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
	my $randid;
	for (my $i; $i < $length; $i++) {
		$randid .= $chararray[int(rand(61))];
	}
	if ($type eq "U") { return uc $randid; } 
	elsif ($type eq "L") { return lc $randid; }
	else { return $randid; }
}

1;