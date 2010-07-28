###############################################################################
# BoardIndex.pl                                                               #
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

$boardindexplver = 'YaBB 2.4 $Revision$';
if ($GLOBAL::ACTION eq 'detailedversion') { return 1; }

&LoadLanguage('BoardIndex');
require "$templatesdir/$useboard/BoardIndex.template";

sub BoardIndex {
	my ($users, $lspostid, $lspostbd, $lssub, $lsposttime, $lsposter, $lsreply, $lsdatetime, $lastthreadtime, @goodboards, @loadboards, $guestlist);
	$totalm = 0;
	$totalt = 0;
	$lastposttime   = 0;
	$lastthreadtime = 0;

	my ($numusers, $guests, $numbots, $user_in_log, $guest_in_log) = (0,0,0,0,0);
	my $lastonline = $date - ($OnlineLogTime * 60);
	foreach (@logentries) {
		($name, $date1, $last_ip, $last_host) = split(/\|/, $_);
		if (!$last_ip) { $last_ip = qq~</i></span><span class="error">$boardindex_txt{'no_ip'}</span><span class="small"><i>~; }
		my $is_a_bot = &Is_Bot($last_host);
		if ($is_a_bot){
			$numbots++;
			$bot_count{$is_a_bot}++;
		} elsif ($name) {
			if (&LoadUser($name)) {
				if ($name eq $username) { $user_in_log = 1; }
				elsif (${$uid.$name}{'lastonline'} < $lastonline) { next; }
				if ($iamadmin || $iamgmod) {
					$numusers++;
					$users .= &QuickLinks($name);
					$users .= (${$uid.$name}{'stealth'} ? "*" : "") .
					          ((($iamadmin && $show_online_ip_admin) || ($iamgmod && $show_online_ip_gmod)) ? "&nbsp;<i>($last_ip)</i>, " : ", ");

				} elsif (!${$uid.$name}{'stealth'}) {
					$numusers++;
					$users .= &QuickLinks($name) . ", ";
				}
			} else {
				if ($name eq $user_ip) { $guest_in_log = 1; }
				$guests++;
				if (($iamadmin && $show_online_ip_admin) || ($iamgmod && $show_online_ip_gmod)) {
					$guestlist .= qq~<i>$last_ip</i>, ~;
				}
			}
		}
	}
	if (!$iamguest && !$user_in_log) {
		$guests-- if $guests;
		$numusers++;
		$users .= &QuickLinks($username);
		if ($iamadmin || $iamgmod) {
			$users .= ${$uid.$username}{'stealth'} ? "*" : "";
			if (($iamadmin && $show_online_ip_admin) || ($iamgmod && $show_online_ip_gmod)) {
				$users .= "&nbsp;<i>($user_ip)</i>";
				$guestlist =~ s|<i>$last_ip</i>, ||o;
			}
		}
	} elsif ($iamguest && !$iambot && !$guest_in_log) {
		$guests++;
	}

	if ($numusers) {
		$users =~ s~, \Z~~;
		$users .= qq~<br />~;
	}
	if ($guestlist) { # build the guest list
		$guestlist =~ s/, $//;
		$guestlist = qq~<span class="small">$guestlist</span><br />~;
	}
	if ($numbots) { # build the bot list
		foreach (sort keys(%bot_count)) { $botlist .= qq~$_&nbsp;($bot_count{$_}), ~; }
		$botlist =~ s/, $//;
		$botlist = qq~<span class="small">$botlist</span>~;
	}

	if (!$INFO{'catselect'}) {
		$yytitle = $boardindex_txt{'18'};
	} else {
		($tmpcat, $tmpmod, $tmpcol) = split(/\|/, $catinfo{ $INFO{'catselect'} });
		&ToChars($tmpcat);
		$yytitle = qq~$tmpcat~;
		$yynavigation = qq~&rsaquo; $tmpcat~;
	}

	if (!$iamguest) { &Collapse_Load; }

	# first get all the boards based on the categories found in forum.master
	foreach $catid (@categoryorder) {
		if ($INFO{'catselect'} ne $catid && $INFO{'catselect'}) { next; }
		$boardlist = $cat{$catid};
		(@bdlist) = split(/\,/, $boardlist);
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{"$catid"});

		# Category Permissions Check
		my $access = &CatAccess($catperms);
		if (!$access) { next; }
		$cat_boardcnt{$catid} = 0;

		# next determine all the boards a user has access to
		foreach $curboard (@bdlist) {
			# now fill all the neccesary hashes to show all board index stuff
			if (!exists $board{$curboard}) {
				&gostRemove($catid, $curboard);
				next;
			}
			# hide the actual global announcement board for all normal users but admins and gmods
			if ($annboard eq $curboard && !$iamadmin && !$iamgmod) { next; }
			my ($boardname, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
			my $access = &AccessCheck($curboard, '', $boardperms);
			if (!$iamadmin && $access ne "granted" && $boardview != 1) { next; }
			push(@goodboards, "$catid|$curboard");
			push(@loadboards, $curboard);
			$cat_boardcnt{$catid}++;
		}
	}

	&BoardTotals("load", @loadboards);
	&getlog;
	my $dmax = $date - ($max_log_days_old * 86400);

	# showcase poll start
	my $polltemp;
	if (&checkfor_DBorFILE("$datadir/poll.showcase")) {
		my $scthreadnum = (&read_DBorFILE(0,'',$datadir,'poll','showcase'))[0];

		# Look for a valid poll file.
		my $pollthread;
		if (&checkfor_DBorFILE("$datadir/$scthreadnum.poll")) {
			&MessageTotals("load",$scthreadnum);
			if ($iamadmin || $iamgmod) {
				$pollthread = 1;
			} else {
				my $curcat = ${$uid.${$scthreadnum}{'board'}}{'cat'};
				my $catperms = (split /\|/,$catinfo{$curcat})[1];
				$pollthread = 1 if &CatAccess($catperms);
				my $boardperms = (split /\|/,$board{${$scthreadnum}{'board'}})[1];
				$pollthread = &AccessCheck(${$scthreadnum}{'board'}, '', $boardperms) eq 'granted' ? $pollthread : 0;
			}
		}

		if ($pollthread) {
			my $tempcurrentboard = $currentboard;
			$currentboard = ${$scthreadnum}{'board'};
			my $tempstaff = $staff;
			$staff = 0 unless $iamadmin || $iamgmod;
			require "$sourcedir/Poll.pl";
			&display_poll($scthreadnum,1);
			$staff = $tempstaff;
			$polltemp = qq~<script language="JavaScript1.2" src="$yyhtml_root/ubbc.js" type="text/javascript"></script>~ . $pollmain . '<br />';
			$currentboard = $tempcurrentboard;
		 }
	}
	# showcase poll end

	foreach $curboard (@loadboards) {
		chomp $curboard;
		$lastposttime = ${$uid.$curboard}{'lastposttime'};
		${$uid.$curboard}{'lastposttime'} = (${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'}) ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposttime'};
		if (${$uid.$curboard}{'lastposttime'} > 0) { $lastposttime{$curboard} = &timeformat(${$uid.$curboard}{'lastposttime'}); }
		else { $lastposttime{$curboard} = $boardindex_txt{'470'}; }
		$lastpostrealtime{$curboard} = (${$uid.$curboard}{'lastposttime'} eq 'N/A' || !${$uid.$curboard}{'lastposttime'}) ? 0 : ${$uid.$curboard}{'lastposttime'};
		$lsreply{$curboard} = ${$uid.$curboard}{'lastreply'} + 1;
		if (${$uid.$curboard}{'lastposter'} =~ m~\AGuest-(.*)~) {
			${$uid.$curboard}{'lastposter'} = $1 . " ($maintxt{'28'})";
			$lastposterguest{$curboard} = 1;
		}
		${$uid.$curboard}{'lastposter'} = ${$uid.$curboard}{'lastposter'} eq 'N/A' || !${$uid.$curboard}{'lastposter'} ? $boardindex_txt{'470'} : ${$uid.$curboard}{'lastposter'};
		${$uid.$curboard}{'messagecount'} = ${$uid.$curboard}{'messagecount'} || 0;
		${$uid.$curboard}{'threadcount'} = ${$uid.$curboard}{'threadcount'} || 0;
		$totalm += ${$uid.$curboard}{'messagecount'};
		$totalt += ${$uid.$curboard}{'threadcount'};

		# hide hidden threads for ordinary members and guests
		my $iammodhere = '';
		foreach my $curuser (split(/, ?/, ${$uid.$curboard}{'mods'})) {
			if ($username eq $curuser) { $iammodhere = 1; }
		}
		foreach my $curgroup (split(/, /, ${$uid.$curboard}{'modgroups'})) {
			if (${$uid.$username}{'position'} eq $curgroup) { $iammodhere = 1; }
			foreach (split(/,/, ${$uid.$username}{'addgroups'})) {
				if ($_ eq $curgroup) { $iammodhere = 1; last; }
			}
		}

		if (!$iammodhere && !$iamadmin && !$iamgmod && ${$uid.$curboard}{'lasttopicstate'} =~ /h/i) {
			${$uid.$curboard}{'lastpostid'} = '';
			${$uid.$curboard}{'lastsubject'} = '';
			${$uid.$curboard}{'lastreply'} = '';
			${$uid.$curboard}{'lastposter'} = $boardindex_txt{'470'};
			${$uid.$curboard}{'lastposttime'} = '';
			$lastposttime{$curboard} = $boardindex_txt{'470'};
			my ($messageid, $messagestate);
			foreach (&read_DBorFILE(0,'',$boardsdir,$curboard,'txt')) {
				($messageid, undef, undef, undef, undef, undef, undef, undef, $messagestate) = split(/\|/, $_);
				if ($messagestate !~ /h/i) {
					next if !(@lastthreadmessages = &read_DBorFILE(0,'',$datadir,$messageid,'txt'));
					my @lastmessage = split(/\|/, $lastthreadmessages[$#lastthreadmessages], 6);
					${$uid.$curboard}{'lastpostid'} = $messageid;
					${$uid.$curboard}{'lastsubject'} = $lastmessage[0];
					${$uid.$curboard}{'lastreply'} = $#lastthreadmessages;
					${$uid.$curboard}{'lastposter'} = $lastmessage[4] eq "Guest" ? qq~Guest-$lastmessage[1]~ : $lastmessage[4];
					${$uid.$curboard}{'lastposttime'} = $lastmessage[3];
					$lastposttime{$curboard} = &timeformat($lastmessage[3]);
					last;
				}
			}
		}

		# determine the true last post on all the boards a user has access to
		if (${$uid.$curboard}{'lastposttime'} > $lastthreadtime && $lastposttime{$curboard} ne $boardindex_txt{'470'}) {
			$lsdatetime = $lastposttime{$curboard};
			$lsposter = ${$uid.$curboard}{'lastposter'};
			$lssub = ${$uid.$curboard}{'lastsubject'};
			$lspostid = ${$uid.$curboard}{'lastpostid'};
			$lsreply = ${$uid.$curboard}{'lastreply'};
			$lastthreadtime = ${$uid.$curboard}{'lastposttime'};
			$lspostbd = $curboard;
		}
	}

	&LoadCensorList;
	foreach $catid (@categoryorder) {
		if ($INFO{'catselect'} ne $catid && $INFO{'catselect'}) { next; }
		my ($catname, $catperms, $catallowcol, $catimage) = split(/\|/, $catinfo{"$catid"});
		&ToChars($catname);

		$cataccess = &CatAccess($catperms);
		if (!$cataccess) { next; }

		# Skip any empty categories.
		if ($cat_boardcnt{$catid} == 0) { next; }

		if (!$iamguest) {
			my $newmsg = 0;
			$newms{$catname} = '';
			$newrowicon{$catname} = '';
			$newrowstart{$catname} = '';
			$newrowend{$catname} = '';
			$collapse_link = '';
			
			if ($catallowcol) {
				$collapse_link = qq~<a href="javascript:SendRequest('$scripturl?action=collapse_cat;cat=$catid','$catid','$imagesdir','$boardindex_exptxt{'2'}','$boardindex_exptxt{'1'}')">~;
			}

			# loop through any collapsed boards to find new posts in it and change the image to match
			# Now shows this whether minimized or not, for Javascript hiding/showing. (Unilat)
			if ($INFO{'catselect'} eq '') {
				foreach my $boardinfo (@goodboards) {
					my $testcat;
					($testcat, $curboard) = split(/\|/, $boardinfo);
					if ($testcat ne $catid) { next; }

					# as we fill the vars based on all boards we need to skip any cat already shown before
					if (!$iamguest && $max_log_days_old && $lastpostrealtime{$curboard} && ((!$yyuserlog{$curboard} && $lastpostrealtime{$curboard} > $dmax) || ($yyuserlog{$curboard} > $dmax && $yyuserlog{$curboard} < $lastpostrealtime{$curboard}))) {
						my (undef, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
						if (&AccessCheck($curboard, '', $boardperms) eq "granted") { $newmsg = 1; }
					}
				}

				if ($catallowcol) {
					$template_catnames .= qq~"$catid",~;
					$newrowend{$catname}   = qq~</span></td></tr>~;
					if ($catcol{$catid}) {
						$newrowstart{$catname} = qq~<tr id="col$catid" style="display:none;"><td colspan="5" class="$new_msg_bg" height="18"><span class="$new_msg_class">~;
						$template_boardtable = qq~id="$catid"~;
					} else {
						$newrowstart{$catname} = qq~<tr id="col$catid"><td colspan="5" class="$new_msg_bg" height="18"><span class="$new_msg_class">~;
						$template_boardtable = qq~id="$catid" style="display:none;"~;
					}
					if ($newmsg) {
						$newrowicon{$catname} = qq~<img src="$imagesdir/on.gif" alt="$boardindex_txt{'333'}" title="$boardindex_txt{'333'}" border="0" style="margin-left: 4px; margin-right: 6px; vertical-align: middle;" />~;
						$newms{$catname} = $boardindex_exptxt{'5'};
					} else {
						$newrowicon{$catname} = qq~<img src="$imagesdir/off.gif" alt="$boardindex_txt{'334'}" title="$boardindex_txt{'334'}" border="0" style="margin-left: 4px; margin-right: 6px; vertical-align: middle;" />~;
						$newms{$catname} = $boardindex_exptxt{'6'};
					}
					if ($catcol{$catid}) {
						$hash{$catname} = qq~<img src="$imagesdir/cat_collapse.gif" id="img$catid" alt="$boardindex_exptxt{'2'}" title="$boardindex_exptxt{'2'}" border="0" /></a>~;
					} else {
						$hash{$catname} = qq~ <img src="$imagesdir/cat_expand.gif" id="img$catid" alt="$boardindex_exptxt{'1'}" title="$boardindex_exptxt{'1'}" border="0" /></a>~;
					}

				} else {
					$template_boardtable = qq~id="$catid"~;
				}

			} else {
				$collapse_link = ''; $hash{$catname} = '';
				$template_boardtable = qq~id="$catid"~;
			}

			$catlink = qq~$collapse_link $hash{$catname} <a href="$scripturl?catselect=$catid" title="$boardindex_txt{'797'} $catname">$catname</a>~;
		} else {
			$template_boardtable = qq~id="$catid"~;
			$catlink = qq~<a href="$scripturl?catselect=$catid">$catname</a>~;
		}

		$templatecat = $catheader;
		$tmpcatimg = "";
		if ($catimage ne '') {
			if ($catimage =~ /\//i) { $catimage = qq~<img src="$catimage" alt="" border="0" style="vertical-align: middle;" />~; }
			elsif ($catimage) { $catimage = qq~<img src="$imagesdir/$catimage" alt="" border="0" style="vertical-align: middle;" />~; }
			$tmpcatimg = qq~$catimage~;
		}
		$templatecat =~ s/({|<)yabb catimage(}|>)/$tmpcatimg/g;
		$templatecat =~ s/({|<)yabb catlink(}|>)/$catlink/g;
		$templatecat =~ s/({|<)yabb newmsg start(}|>)/$newrowstart{$catname}/g;
		$templatecat =~ s/({|<)yabb newmsg icon(}|>)/$newrowicon{$catname}/g;
		$templatecat =~ s/({|<)yabb newmsg(}|>)/$newms{$catname}/g;
		$templatecat =~ s/({|<)yabb newmsg end(}|>)/$newrowend{$catname}/g;
		$templatecat =~ s/({|<)yabb boardtable(}|>)/$template_boardtable/g;
		$tmptemplateblock .= $templatecat;

		## loop through any non collapsed boards to show the board index
		## Also shows whether collapsed or not due to QuickCollapse (Unilat)
		if (!$INFO{'oldcollapse'} || $catcol{$catid} || $INFO{'catselect'} ne '' || $iamguest) {
			foreach my $boardinfo (@goodboards) {
				my $testcat;
				($testcat, $curboard) = split(/\|/, $boardinfo);
				if ($testcat ne $catid) { next; }
				# as we fill the vars based on all boards we need to skip any cat already shown before
				if (${$uid.$curboard}{'ann'} == 1) { ${$uid.$curboard}{'pic'} = 'ann.gif'; }
				if (${$uid.$curboard}{'rbin'} == 1) { ${$uid.$curboard}{'pic'} = 'recycle.gif'; }
				($boardname, $boardperms, $boardview) = split(/\|/, $board{$curboard});
				&ToChars($boardname);
				$INFO{'zeropost'} = 0;
				$zero = '';
				$bdpic = ${$uid.$curboard}{'pic'};
				$bddescr = ${$uid.$curboard}{'description'};
				&ToChars($bddescr);
				$iammod = '';
				%moderators = ();
				foreach my $curuser (split(/, ?/, ${$uid.$curboard}{'mods'})) {
					if ($username eq $curuser) { $iammod = 1; }
					&LoadUser($curuser);
					$moderators{$curuser} = ${$uid.$curuser}{'realname'};
				}
				$showmods = '';
				if (keys %moderators == 1) { $showmods = qq~$boardindex_txt{'298'}: ~; }
				elsif (keys %moderators != 0) { $showmods = qq~$boardindex_txt{'63'}: ~; }
				while ($tmpa = each(%moderators)) {
					&FormatUserName($tmpa);
					$showmods .= &QuickLinks($tmpa,1) . ", ";
				}
				$showmods =~ s/, \Z//;

				%moderatorgroups = ();
				foreach my $curgroup (split(/, /, ${$uid.$curboard}{'modgroups'})) {
					if (${$uid.$username}{'position'} eq $curgroup) { $iammod = 1; }
					foreach (split(/,/, ${$uid.$username}{'addgroups'})) {
						if ($_ eq $curgroup) { $iammod = 1; last; }
					}
					($thismodgrp, undef) = split(/\|/, $NoPost{$curgroup}, 2);
					$moderatorgroups{$curgroup} = $thismodgrp;
				}

				$showmodgroups = '';
				if (scalar keys %moderatorgroups == 1) { $showmodgroups = qq~$boardindex_txt{'298a'}: ~; }
				elsif (scalar keys %moderatorgroups != 0) { $showmodgroups = qq~$boardindex_txt{'63a'}: ~; }
				while ($tmpa = each(%moderatorgroups)) {
					$showmodgroups .= qq~$moderatorgroups{$tmpa}, ~;
				}
				$showmodgroups =~ s/, \Z//;
				if ($showmodgroups eq "" && $showmods eq "") { $showmodgroups = qq~<br />~; }
				if ($showmodgroups ne "" && $showmods ne "") { $showmods .= qq~<br />~; }

				if ($iamguest) {
					$new = '';

				} elsif ($max_log_days_old && $lastpostrealtime{$curboard} && ((!$yyuserlog{$curboard} && $lastpostrealtime{$curboard} > $dmax) || ($yyuserlog{$curboard} > $dmax && $yyuserlog{$curboard} < $lastpostrealtime{$curboard}))) {
					my (undef, $boardperms, $boardview) = split(/\|/, $board{"$curboard"});
					if (&AccessCheck($curboard, '', $boardperms) eq "granted") {
						$new = qq~<img src="$imagesdir/on.gif" alt="$boardindex_txt{'333'}" title="$boardindex_txt{'333'}" border="0" style="vertical-align: middle;" />~;
					} else {
						$new = qq~<img src="$imagesdir/off.gif" alt="$boardindex_txt{'334'}" title="$boardindex_txt{'334'}" border="0" style="vertical-align: middle;" />~;
					}

				} else {
					$new = qq~<img src="$imagesdir/off.gif" alt="$boardindex_txt{'334'}" title="$boardindex_txt{'334'}" border="0" style="vertical-align: middle;" />~;
				}
				if (!$bdpic) { $bdpic = 'boards.gif'; }

				$lastposter = ${$uid.$curboard}{'lastposter'};
				$lastposter =~ s~\AGuest-(.*)~$1 ($maintxt{'28'})~i;

				unless ($lastposterguest{$curboard} || ${$uid.$curboard}{'lastposter'} eq $boardindex_txt{'470'}) {
					&LoadUser($lastposter);
					if ((${$uid.$lastposter}{'regdate'} && ${$uid.$curboard}{'lastposttime'} > ${$uid.$lastposter}{'regtime'}) || ${$uid.$lastposter}{'position'} eq "Administrator" || ${$uid.$lastposter}{'position'} eq "Global Moderator") {
						$lastposter = qq~<a href="$scripturl?action=viewprofile;username=$useraccount{$lastposter}" rel="nofollow">${$uid.$lastposter}{'realname'}</a>~;
					} else {
						# Need to load thread to see lastposters DISPLAYname if is Ex-Member
						my @x = &read_DBorFILE(0,'',$datadir,${$uid.$curboard}{'lastpostid'},'txt');
						$lastposter = (split(/\|/, $x[$#x], 3))[1] . " - $boardindex_txt{'470a'}";
					}
				}
				${$uid.$curboard}{'lastposter'} ||= $boardindex_txt{'470'};
				${$uid.$curboard}{'lastposttime'} ||= $boardindex_txt{'470'};

				if ($bdpic =~ /\//i) { $bdpic = qq~ <img src="$bdpic" alt="$boardname" title="$boardname" border="0" align="middle" /> ~; }
				elsif ($bdpic) { $bdpic = qq~ <img src="$imagesdir/$bdpic" alt="$boardname" title="$boardname" border="0" /> ~; }

				my $templateblock = $boardblock;

				my $lasttopictxt = ${$uid.$curboard}{'lastsubject'};
				($lasttopictxt, undef) = &Split_Splice_Move($lasttopictxt,0);
				my $fulltopictext = $lasttopictxt;

				$convertstr = $lasttopictxt;
				$convertcut = $topiccut ? $topiccut : 15;
				&CountChars;
				$lasttopictxt = $convertstr;
				if ($cliped) { $lasttopictxt .= "..."; }

				&ToChars($lasttopictxt);
				$lasttopictxt = &Censor($lasttopictxt);

				&ToChars($fulltopictext);
				$fulltopictext = &Censor($fulltopictext);

				if (${$uid.$curboard}{'lastreply'} ne "") {
					$lastpostlink = qq~<a href="$scripturl?num=${$uid.$curboard}{'lastpostid'}/${$uid.$curboard}{'lastreply'}#${$uid.$curboard}{'lastreply'}" title="$boardindex_txt{'22'}">$img{'lastpost'}</a> $lastposttime{$curboard}~;
				} else {
					$lastpostlink = qq~$img{'lastpost'} $boardindex_txt{'470'}~;
				}

				my $boardanchor = $curboard;
				if($boardanchor =~ m~\A[^az]~i) {$boardanchor =~ s~(.*?)~b$1~;}
				my $lasttopiclink = qq~<a href="$scripturl?num=${$uid.$curboard}{'lastpostid'}/${$uid.$curboard}{'lastreply'}#${$uid.$curboard}{'lastreply'}" title="$fulltopictext">$lasttopictxt</a>~;
				if (${$uid.$curboard}{'threadcount'} < 0)  { ${$uid.$curboard}{'threadcount'}  = 0; }
				if (${$uid.$curboard}{'messagecount'} < 0) { ${$uid.$curboard}{'messagecount'} = 0; }
				$templateblock =~ s/({|<)yabb boardanchor(}|>)/$boardanchor/g;
				$templateblock =~ s/({|<)yabb boardurl(}|>)/$scripturl\?board\=$curboard/g;
				$templateblock =~ s/({|<)yabb new(}|>)/$new/g;
				$templateblock =~ s/({|<)yabb boardpic(}|>)/$bdpic/g;
				$templateblock =~ s/({|<)yabb boardname(}|>)/$boardname/g;
				$templateblock =~ s/({|<)yabb boarddesc(}|>)/$bddescr/g;
				$templateblock =~ s/({|<)yabb moderators(}|>)/$showmods$showmodgroups/g;
				$templateblock =~ s/({|<)yabb threadcount(}|>)/ &NumberFormat(${$uid.$curboard}{'threadcount'}) /e;
				$templateblock =~ s/({|<)yabb messagecount(}|>)/ &NumberFormat(${$uid.$curboard}{'messagecount'}) /e;
				$templateblock =~ s/({|<)yabb lastpostlink(}|>)/$lastpostlink/g;
				$templateblock =~ s/({|<)yabb lastposter(}|>)/$lastposter/g;
				$templateblock =~ s/({|<)yabb lasttopiclink(}|>)/$lasttopiclink/g;
				$tmptemplateblock .= $templateblock;
			}
		}
		$tmptemplateblock .= $catfooter;
		++$catcount;
	}

	if (!$iamguest) {
		if (${$uid.$username}{'im_imspop'}) {
			$yymain .= qq~\n\n<script language="JavaScript1.2" type="text/javascript">
<!--
	function viewIM() { window.open("$scripturl?action=im"); }
	function viewIMOUT() { window.open("$scripturl?action=imoutbox"); }
	function viewIMSTORE() { window.open("$scripturl?action=imstorage"); }
// -->
</script>~;
		} else {
			$yymain .= qq~\n\n<script language="JavaScript1.2" type="text/javascript">
<!--
	function viewIM() { location.href = ("$scripturl?action=im"); }
	function viewIMOUT() { location.href = ("$scripturl?action=imoutbox"); }
	function viewIMSTORE() { location.href = ("$scripturl?action=imstorage"); }
// -->
</script>~;
		}
		my $imsweredeleted = 0;
		if (${$username}{'PMmnum'} > $numibox && $numibox && $enable_imlimit) {
			&Del_Max_IM('msg',$numibox);
			$imsweredeleted = ${$username}{'PMmnum'} - $numibox;
			$yymain .= qq~\n<script language="JavaScript1.2" type="text/javascript">
<!--
	if (confirm('$boardindex_imtxt{'11'} ${$username}{'PMmnum'} $boardindex_imtxt{'12'} $boardindex_txt{'316'}, $boardindex_imtxt{'16'} $numibox $boardindex_imtxt{'18'}. $boardindex_imtxt{'19'} $imsweredeleted $boardindex_imtxt{'20'} $boardindex_txt{'316'} $boardindex_imtxt{'21'}')) viewIM();
// -->
</script>~;
			${$username}{'PMmnum'} = $numibox;
		}
		if (${$username}{'PMmoutnum'} > $numobox && $numobox && $enable_imlimit) {
			&Del_Max_IM('outbox',$numobox);
			$imsweredeleted = ${$username}{'PMmoutnum'} - $numobox;
			$yymain .= qq~\n<script language="JavaScript1.2" type="text/javascript">
<!--
	if (confirm('$boardindex_imtxt{'11'} ${$username}{'PMmoutnum'} $boardindex_imtxt{'12'} $boardindex_txt{'320'}, $boardindex_imtxt{'16'} $numobox $boardindex_imtxt{'18'}. $boardindex_imtxt{'19'} $imsweredeleted $boardindex_imtxt{'20'} $boardindex_txt{'320'} $boardindex_imtxt{'21'}')) viewIMOUT();
// -->
</script>~;
			${$username}{'PMmoutnum'} = $numobox;
		}
		if (${$username}{'PMstorenum'} > $numstore && $numstore && $enable_imlimit) {
			&Del_Max_IM('imstore',$numstore);
			$imsweredeleted = ${$username}{'PMstorenum'} - $numstore;
			$yymain .= qq~\n<script language="JavaScript1.2" type="text/javascript">
<!--
	if (confirm('$boardindex_imtxt{'11'} ${$username}{'PMstorenum'} $boardindex_imtxt{'12'} $boardindex_imtxt{'46'}, $boardindex_imtxt{'16'} $numstore $boardindex_imtxt{'18'}. $boardindex_imtxt{'19'} $imsweredeleted $boardindex_imtxt{'20'} $boardindex_imtxt{'46'} $boardindex_imtxt{'21'}')) viewIMSTORE();
// -->
</script>~;
			${$username}{'PMstorenum'} = $numstore;
		}
		if ($imsweredeleted) {
			&buildIMS($username, 'update');
			&LoadIMs();
		}

		$ims = '';
		if ($PM_level == 1 || ($PM_level == 2 && $staff) || ($PM_level == 3 && ($iamadmin || $iamgmod))){
			$ims = qq~$boardindex_txt{'795'} <a href="$scripturl?action=im"><b>${$username}{'PMmnum'}</b></a> $boardindex_txt{'796'}~;
			if (${$username}{'PMmnum'} > 0) {
				if (${$username}{'PMimnewcount'} == 1) {
					$ims .= qq~ $boardindex_imtxt{'24'} <a href="$scripturl?action=im"><b>${$username}{'PMimnewcount'}</b></a> $boardindex_imtxt{'25'}.~;
				} else {
					$ims .= qq~ $boardindex_imtxt{'24'} <a href="$scripturl?action=im"><b>${$username}{'PMimnewcount'}</b></a> $boardindex_imtxt{'26'}.~;
				}
			} else {
				$ims .= qq~.~;
			}
		}

		if ($INFO{'catselect'} eq '') {
			if ($colbutton) { $col_vis = ""; }
			else { $col_vis = " style='display:none;'"; }
			if (${$uid.$username}{'cathide'}) { $exp_vis = ""; }
			else { $exp_vis = " style='display:none;'"; }

			$expandlink = qq~<span id="expandall" $exp_vis><a href="javascript:Collapse_All('$scripturl?action=collapse_all;status=1',1,'$imagesdir','$boardindex_exptxt{'2'}')">$img{'expand'}</a>$menusep</span>~;
			$collapselink = qq~<span id="collapseall" $col_vis><a href="javascript:Collapse_All('$scripturl?action=collapse_all;status=0',0,'$imagesdir','$boardindex_exptxt{'1'}')">$img{'collapse'}</a>$menusep</span>~;
			$markalllink = qq~<a href="javascript:MarkAllAsRead('$scripturl?action=markallasread','$imagesdir')">$img{'markallread'}</a>~;

		} else {
			$markalllink  = qq~<a href="javascript:MarkAllAsRead('$scripturl?action=markallasread;cat=$INFO{'catselect'}','$imagesdir')">$img{'markallread'}</a>~;
			$collapselink = '';
			$expandlink   = '';
		}
	}

	if ($totalt < 0) { $totalt = 0; }
	if ($totalm < 0) { $totalm = 0; }

	$guestson = qq~<span class="small">$boardindex_txt{'141'}: <b>$guests</b></span>~;
	$userson = qq~<span class="small">$boardindex_txt{'142'}: <b>$numusers</b></span>~;
	$botson = qq~<span class="small">$boardindex_txt{'143'}: <b>$numbots</b></span>~;

	$totalusers = $numusers + $guests;

	if (!&checkfor_DBorFILE("$vardir/mostlog.txt")) {
		&write_DBorFILE(0,'',$vardir,'mostlog','txt',("$numusers|$date\n","$guests|$date\n","$totalusers|$date\n","$numbots|$date\n"));
	}
	@mostentries = &read_DBorFILE(1,'',$vardir,'mostlog','txt');
	($mostmemb, $datememb) = split(/\|/, $mostentries[0]);
	($mostguest, $dateguest) = split(/\|/, $mostentries[1]);
	($mostusers, $dateusers) = split(/\|/, $mostentries[2]);
	($mostbots, $datebots) = split(/\|/, $mostentries[3]);
	chomp ($datememb, $dateguest, $dateusers, $datebots);
	if ($numusers > $mostmemb || $guests > $mostguest || $numbots > $mostbots || $totalusers > $mostusers) {
		if ($numusers > $mostmemb) { $mostmemb = $numusers; $datememb = $date; }
		if ($guests > $mostguest) { $mostguest = $guests; $dateguest = $date; }
		if ($totalusers > $mostusers) { $mostusers = $totalusers; $dateusers = $date; }
		if ($numbots > $mostbots) { $mostbots  = $numbots; $datebots = $date; }

		&write_DBorFILE(0,'',$vardir,'mostlog','txt',("$mostmemb|$datememb\n","$mostguest|$dateguest\n","$mostusers|$dateusers\n","$mostbots|$datebots\n"));
	}
	$themostmembdate = &timeformat($datememb);
	$themostguestdate = &timeformat($dateguest);
	$themostuserdate = &timeformat($dateusers);
	$themostbotsdate = &timeformat($datebots);

	my $shared_login;
	if ($iamguest) {
		require "$sourcedir/LogInOut.pl";
		$sharedLogin_title = '';
		$shared_login = &sharedLogin;
	}

	my %tmpcolors;
	$tmpcnt = 0;
	$grpcolors = '';
	($title, undef, undef, $color, $noshow, undef) = split(/\|/, $Group{'Administrator'}, 6);
	if ($color && $noshow != 1) {
		$tmpcnt++;
		$tmpcolors{$tmpcnt} = qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
	}
	($title, undef, undef, $color, $noshow, undef) = split(/\|/, $Group{'Global Moderator'}, 6);
	if ($color && $noshow != 1) {
		$tmpcnt++;
		$tmpcolors{$tmpcnt} = qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
	}
	foreach (@nopostorder) {
		($title, undef, undef, $color, $noshow, undef) = split(/\|/, $NoPost{$_}, 6);
		if ($color && $noshow != 1) {
			$tmpcnt++;
			$tmpcolors{$tmpcnt} = qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
		}
	}
	foreach $postamount (sort { $b <=> $a } keys %Post) {
		($title, undef, undef, $color, $noshow, undef) = split(/\|/, $Post{$postamount}, 6);
		if ($color && $noshow != 1) {
			$tmpcnt++;
			$tmpcolors{$tmpcnt} = qq~<div class="small" style="float: left; width: 49%;"><span style="color: $color;"><b>lllll</b></span> $title</div>~;
		}
	}
	$rows = int(($tmpcnt / 2) + 0.5);
	$col1 = 1;
	for(1..$rows) {
		$col2 = $rows + $col1;
		if($tmpcolors{$col1}) { $grpcolors .= qq~$tmpcolors{$col1}~; }
		if($tmpcolors{$col2}) { $grpcolors .= qq~$tmpcolors{$col2}~; }
		$col1++;
	}
	undef %tmpcolors;

	# Template it
	my ($rss_link, $rss_text);
	if (!$rss_disabled) {
		$rss_link = qq~<a href="$scripturl?action=RSSrecent" target="_blank"><img src="$imagesdir/rss.png" border="0" alt="$main_txt{'rssfeed'}" title="$main_txt{'rssfeed'}" style="vertical-align: middle;" /></a>~;
		$rss_link = qq~<a href="$scripturl?action=RSSrecent;catselect=$INFO{'catselect'}" target="_blank"><img src="$imagesdir/rss.png" border="0" alt="$main_txt{'rssfeed'}" title="$main_txt{'rssfeed'}" style="vertical-align: middle;" /></a>~ if $INFO{'catselect'};
		$rss_text = qq~<a href="$scripturl?action=RSSrecent" target="_blank">$boardindex_txt{'792'}</a>~;
		$rss_text = qq~<a href="$scripturl?action=RSSrecent;catselect=$INFO{'catselect'}" target="_blank">$boardindex_txt{'792'}</a>~ if $INFO{'catselect'};
	}
	$yyrssfeed = $rss_text;
	$yyrss = $rss_link;
	$boardindex_template =~ s/({|<)yabb rssfeed(}|>)/$rss_text/g;
	$boardindex_template =~ s/({|<)yabb rss(}|>)/$rss_link/g;

	$boardindex_template =~ s/({|<)yabb navigation(}|>)/&nbsp;/g;
	$boardindex_template =~ s/({|<)yabb pollshowcase(}|>)/$polltemp/g;
	$boardindex_template =~ s/({|<)yabb selecthtml(}|>)//g;
	$boardindex_template =~ s/({|<)yabb catsblock(}|>)/$tmptemplateblock/g;

	$boardhandellist     =~ s/({|<)yabb collapse(}|>)/$collapselink/g;
	$boardhandellist     =~ s/({|<)yabb expand(}|>)/$expandlink/g;
	$boardhandellist     =~ s/({|<)yabb markallread(}|>)/$markalllink/g;

	$boardindex_template =~ s/({|<)yabb boardhandellist(}|>)/$boardhandellist/g;
	$boardindex_template =~ s/({|<)yabb totaltopics(}|>)/ &NumberFormat($totalt) /e;
	$boardindex_template =~ s/({|<)yabb totalmessages(}|>)/ &NumberFormat($totalm) /e;

	if ($Show_RecentBar) {
		($lssub, undef) = &Split_Splice_Move($lssub,0);
		&ToChars($lssub);
		$lssub = &Censor($lssub);
		$tmlsdatetime    = qq~($lsdatetime).<br />~;
		$lastpostlink    = qq~$boardindex_txt{'236'} <b><a href="$scripturl?num=$lspostid/$lsreply#$lsreply"><b>$lssub</b></a></b>~;

		if ($maxrecentdisplay > 0) {
			$recentpostslink = qq~$boardindex_txt{'791'} <form method="post" action="$scripturl?action=recent" name="recent" style="display: inline"><select size="1" name="display" onchange="submit()"><option value="">&nbsp;</option>~;
			my ($x,$y) = (int($maxrecentdisplay/5),0);
			if ($x) {
				for (my $i = 1; $i <= 5; $i++) {
					$y = $i * $x;
					$recentpostslink .= qq~<option value="$y">$y</option>~;
				}
			}
			$recentpostslink .= qq~<option value="$maxrecentdisplay">$maxrecentdisplay</option>~ if $maxrecentdisplay > $y;
			$recentpostslink .= qq~</select> </form> $boardindex_txt{'792'} $boardindex_txt{'793'}~;
		}

		$boardindex_template =~ s/({|<)yabb lastpostlink(}|>)/$lastpostlink/g;
		$boardindex_template =~ s/({|<)yabb recentposts(}|>)/$recentpostslink/g;
		$boardindex_template =~ s/({|<)yabb lastpostdate(}|>)/$tmlsdatetime/g;
	} else {
		$boardindex_template =~ s/({|<)yabb lastpostlink(}|>)//g;
		$boardindex_template =~ s/({|<)yabb recentposts(}|>)//g;
		$boardindex_template =~ s/({|<)yabb lastpostdate(}|>)//g;
	}
	$boardindex_template =~ s~({|<)yabb membercount(}|>)~ qq*<a href="$scripturl?action=ml"><b>* . &NumberFormat($members_total). qq*</b></a>* ~e;
	if ($showlatestmember) {
		&LoadUser($last_member);
		$boardindex_template =~ s/({|<)yabb latestmember(}|>)/qq~$boardindex_txt{'201'} ~ . &QuickLinks($last_member) . qq~.<br \/>~/eg;
	} else {
		$boardindex_template =~ s/({|<)yabb latestmember(}|>)//g;
	}
	$boardindex_template =~ s/({|<)yabb ims(}|>)/$ims/g;
	$boardindex_template =~ s/({|<)yabb guests(}|>)/$guestson/g;
	$boardindex_template =~ s/({|<)yabb users(}|>)/$userson/g;
	$boardindex_template =~ s/({|<)yabb bots(}|>)/$botson/g;
	$boardindex_template =~ s/({|<)yabb onlineusers(}|>)/$users/g;
	$boardindex_template =~ s/({|<)yabb onlineguests(}|>)/$guestlist/g;
	$boardindex_template =~ s/({|<)yabb onlinebots(}|>)/$botlist/g;
	$boardindex_template =~ s/({|<)yabb mostmembers(}|>)/ &NumberFormat($mostmemb) /e;
	$boardindex_template =~ s/({|<)yabb mostguests(}|>)/ &NumberFormat($mostguest) /e;
	$boardindex_template =~ s/({|<)yabb mostbots(}|>)/ &NumberFormat($mostbots) /e;
	$boardindex_template =~ s/({|<)yabb mostusers(}|>)/ &NumberFormat($mostusers) /e;
	$boardindex_template =~ s/({|<)yabb mostmembersdate(}|>)/$themostmembdate/g;
	$boardindex_template =~ s/({|<)yabb mostguestsdate(}|>)/$themostguestdate/g;
	$boardindex_template =~ s/({|<)yabb mostbotsdate(}|>)/$themostbotsdate/g;
	$boardindex_template =~ s/({|<)yabb mostusersdate(}|>)/$themostuserdate/g;
	$boardindex_template =~ s/({|<)yabb groupcolors(}|>)/$grpcolors/g;
	$boardindex_template =~ s/({|<)yabb sharedlogin(}|>)/$shared_login/g;
	# EventCal START
	my $cal_display;
	if ($Show_EventCal == 2 || (!$iamguest && $Show_EventCal == 1)) {
		require "$sourcedir/EventCal.pl";
		$cal_display = &get_cal;
	}
	$boardindex_template =~ s/({|<)yabb caldisplay(}|>)/$cal_display/g;
	# EventCal END

	chop($template_catnames);
	$yyjavascript .= qq~\nvar markallreadlang = '$boardindex_txt{'500'}';\nvar markfinishedlang = '$boardindex_txt{'500a'}';~;
	$yymain .= qq~\n
<script language="JavaScript1.2" src="$yyhtml_root/ajax.js" type="text/javascript"></script>
<script language="JavaScript1.2" type="text/javascript">
<!--
	var catNames = [$template_catnames];
//-->
</script>
$boardindex_template~;

	if (${$username}{'PMimnewcount'} > 0) {
		if (${$username}{'PMimnewcount'} > 1) { $en = 's'; $en2 = $boardindex_imtxt{'47'}; }
		else { $en = ''; $en2 = $boardindex_imtxt{'48'}; }

		if (${$uid.$username}{'im_popup'}) {
			if (${$uid.$username}{'im_imspop'}) {
				$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!--
	if (confirm("$boardindex_imtxt{'14'} ${$username}{'PMimnewcount'}$boardindex_imtxt{'15'}?")) window.open("$scripturl?action=im","_blank");
// -->
</script>~;
			} else {
				$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!--
	if (confirm("$boardindex_imtxt{'14'} ${$username}{'PMimnewcount'}$boardindex_imtxt{'15'}?")) location.href = ("$scripturl?action=im");
// -->
</script>~;
			}
		}
	}

	&LoadBroadcastMessages($username); # look for new BM
	if ($BCnewMessage) {
		if (${$uid.$username}{'im_imspop'}) {
			$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!--
	if (confirm("$boardindex_imtxt{'50'}$boardindex_imtxt{'51'}?")) window.open("$scripturl?action=im;focus=bmess","_blank");
// -->
</script>~;
		} else {
				$yymain .= qq~
<script language="JavaScript1.2" type="text/javascript">
<!--
	if (confirm("$boardindex_imtxt{'50'}$boardindex_imtxt{'51'}?")) location.href = ("$scripturl?action=im;focus=bmess");
// -->
</script>~;
		}
	}

	# Make browsers aware of our RSS
	if (!$rss_disabled) {
		if ($INFO{'catselect'}) { # Handle categories properly
			$yyinlinestyle .= qq~<link rel="alternate" type="application/rss+xml" title="$boardindex_txt{'792'}" href="$scripturl?action=RSSrecent;catselect=$INFO{'catselect'}" />\n~;
		} else {
			$yyinlinestyle .= qq~<link rel="alternate" type="application/rss+xml" title="$boardindex_txt{'792'}" href="$scripturl?action=RSSrecent" />\n~;
		}
	}

	&template;
}

sub Collapse_Write {
	my @userhide;

	# rewrite the category hash for the user
	foreach my $key (@categoryorder) {
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{$key});
		$access = &CatAccess($catperms);
		if ($catcol{$key} == 0 && $access) { push(@userhide, $key); }
	}
	${$uid.$username}{'cathide'} = join(",", @userhide);
	&UserAccount($username, "update");
	if (&checkfor_DBorFILE("$memberdir/$username.cat")) { &delete_DBorFILE("$memberdir/$username.cat"); }
}

sub Collapse_Cat {
	if ($iamguest) { &fatal_error("collapse_no_member"); }
	my $changecat = $INFO{'cat'};
	unless ($colloaded) { &Collapse_Load; }

	if ($catcol{$changecat} eq 1) {
		$catcol{$changecat} = 0;
	} else {
		$catcol{$changecat} = 1;
	}
	&Collapse_Write;
	if ($INFO{'oldcollapse'}) {
		$yySetLocation = $scripturl;
		&redirectexit;
	}
	$elenable = 0;
	die ""; # This is here only to avoid server error log entries!
}

sub Collapse_All {
	my ($state, @catstatus);
	$state = $INFO{'status'};

	if ($iamguest) { &fatal_error("collapse_no_member"); }
	if ($state != 1 && $state != 0) { &fatal_error("collapse_invalid_state"); }

	foreach my $key (@categoryorder) {
		my ($catname, $catperms, $catallowcol) = split(/\|/, $catinfo{$key});
		if ($catallowcol eq '1') {
			$catcol{$key} = $state;
		} else {
			$catcol{$key} = 1;
		}
	}
	&Collapse_Write;
	if ($INFO{'oldcollapse'}) {
		$yySetLocation = $scripturl;
		&redirectexit;
	}
	$elenable = 0;
	die ""; # This is here only to avoid server error log entries!
}

sub MarkAllRead { # Mark all boards as read.
	my @cats = ();
	if ($INFO{'cat'}) { @cats = ($INFO{'cat'}); $INFO{'catselect'} = $INFO{'cat'};}
	else { @cats = @categoryorder; }

	# Load the whole log
	&getlog;

	foreach my $catid (@cats) {
		# Security check
		unless (&CatAccess((split /\|/, $catinfo{$catid})[1])) {
			foreach my $board (split(/\,/, $cat{$catid})) {
				delete $yyuserlog{"$board--mark"};
				delete $yyuserlog{$board};
			}
			next;
		}

		foreach my $board (split(/\,/, $cat{$catid})) {
			# Security check
			if (&AccessCheck($board, '', (split /\|/, $board{$board})[1]) ne 'granted') {
				delete $yyuserlog{"$board--mark"};
				delete $yyuserlog{$board};
			} else {
				# Mark it
				$yyuserlog{"$board--mark"} = $date;
				$yyuserlog{$board} = $date;
			}
		}
	}

	# Write it out
	&dumplog();

	if ($INFO{'oldmarkread'}) {
		&redirectinternal;
	}
	$elenable = 0;
	die ""; # This is here only to avoid server error log entries!
}

sub gostRemove {
	$thecat    = $_[0];
	$gostboard = $_[1];
	(@gbdlist) = split(/\,/, $cat{$thecat});
	$tmp_master = '';
	foreach $item (@gbdlist) {
		if ($item ne $gostboard) {
			$tmp_master .= qq~$item,~;
		}
	}
	$tmp_master =~ s/,\Z//;
	$cat{$thecat} = $tmp_master;
	&Write_ForumMaster;
}

sub Del_Max_IM {
	my ($ext,$max) = @_;
	my @IMmessages = &read_DBorFILE(0,DELMAXIM,$memberdir,$username,$ext);
	splice(@IMmessages,$max);
	&write_DBorFILE(0,DELMAXIM,$memberdir,$username,$ext,@IMmessages);
}

1;
