###############################################################################
# TabMenu.pl                                                                  #
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

$tabmenuplver = 'YaBB 2.4 $Revision$';
if ($GLOBAL::ACTION eq 'detailedversion') { return 1; }

&LoadLanguage('TabMenu');

my ($tab_lang);

$tabsep = qq~<img src="$imagesdir/tabsep211.png" border="0" alt="" style="float: left; vertical-align: middle;" />~;
$tabfill = qq~<img src="$imagesdir/tabfill.gif" border="0" alt="" style="vertical-align: middle;" />~;

sub mainMenu {
	if ($GLOBAL::ACTION eq "addtab" && $iamadmin) { require "$sourcedir/AdvancedTabs.pl"; &AddNewTab; }
	elsif ($GLOBAL::ACTION eq "edittab" && $iamadmin) { require "$sourcedir/AdvancedTabs.pl"; &EditTab; }
	elsif ($GLOBAL::ACTION ne "") {
		if ($GLOBAL::ACTION eq "search2") {
			$tmpaction = "search";
		} elsif ($GLOBAL::ACTION eq "favorites" || $GLOBAL::ACTION eq "shownotify" || $GLOBAL::ACTION eq "im" || $GLOBAL::ACTION eq "imdraft" || $GLOBAL::ACTION eq "imoutbox" || $GLOBAL::ACTION eq "imstorage" || $GLOBAL::ACTION eq "imsend" || $GLOBAL::ACTION eq "imsend2" || $GLOBAL::ACTION eq "imshow" || $GLOBAL::ACTION eq "profileCheck" || $GLOBAL::ACTION eq "myviewprofile" || $GLOBAL::ACTION eq "myprofile" || $GLOBAL::ACTION eq "myprofileContacts" || $GLOBAL::ACTION eq "myprofileOptions" || $GLOBAL::ACTION eq "myprofileBuddy" || $GLOBAL::ACTION eq "myprofileIM" || $GLOBAL::ACTION eq "myprofileAdmin" || $GLOBAL::ACTION eq "myusersrecentposts") {
			$tmpaction = "mycenter";
		} elsif ($GLOBAL::ACTION eq "messagepagetext" || $GLOBAL::ACTION eq "messagepagedrop" || $GLOBAL::ACTION eq "threadpagetext" || $GLOBAL::ACTION eq "threadpagedrop" || $GLOBAL::ACTION eq "post" || $GLOBAL::ACTION eq "notify" || $GLOBAL::ACTION eq "boardnotify" || $GLOBAL::ACTION eq "sendtopic" || $GLOBAL::ACTION eq "modify") {
			$tmpaction = "home";
		} elsif ($GLOBAL::ACTION eq "guestpm2") {
			$tmpaction = "guestpm";
		} else { $tmpaction = $GLOBAL::ACTION; }

	} else {
		$tmpaction = "home";
	}

	$tab{'home'} = qq~<span |><a href="$scripturl" title="$img_txt{'103'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'103'}$tabfill</a></span>~;
	$tab{'help'} = qq~<span |><a href="$scripturl?action=help" title="$img_txt{'119'}" style="padding: 3px 0 4px 0; cursor:help;">$tabfill$img_txt{'119'}$tabfill</a></span>~;
	if ($maxsearchdisplay > -1) {
		$tab{'search'} = qq~<span |><a href="$scripturl?action=search" title="$img_txt{'182'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'182'}$tabfill</a></span>~;
	}
	if (!$ML_Allowed || ($ML_Allowed == 1 && !$iamguest) || ($ML_Allowed == 2 && $staff) || ($ML_Allowed == 3 && ($iamadmin || $iamgmod))) {
		$tab{'ml'} = qq~<span |><a href="$scripturl?action=ml" title="$img_txt{'331'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'331'}$tabfill</a></span>~;
	}
	if ($iamadmin) {
		$tab{'admin'} = qq~<span |><a href="$boardurl/AdminIndex.$yyaext" title="$img_txt{'2'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'2'}$tabfill</a></span>~;
	}
	if ($iamgmod) {
		if (-e "$vardir/gmodsettings.txt") { require "$vardir/gmodsettings.txt"; }
		if ($allow_gmod_admin) {
			$tab{'admin'} = qq~<span |><a href="$boardurl/AdminIndex.$yyaext" title="$img_txt{'2'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'2'}$tabfill</a></span>~;
		}
	}
	if ($sessionvalid == 0 && !$iamguest) {
		my $sesredir;
		unless (!$testenv || $GLOBAL::ACTION eq "revalidatesession" || $GLOBAL::ACTION eq "revalidatesession2") {
			$sesredir = $testenv;
			$sesredir =~ s/\=/\~/g;
			$sesredir =~ s/;/x3B/g;
			$sesredir = qq~;sesredir=$sesredir~;
		}
		$tab{'revalidatesession'} = qq~<span |><a href="$scripturl?action=revalidatesession$sesredir" title="$img_txt{'34a'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'34a'}$tabfill</a></span>~;
	}
	if ($iamguest) {
		my $sesredir;
		if ($testenv) {
			$sesredir = $testenv;
			$sesredir =~ s/\=/\~/g;
			$sesredir =~ s/;/x3B/g;
			$sesredir = qq~;sesredir=$sesredir~;
		}
		$tab{'login'} = qq~<span |><a href="~ . ($loginform ? "javascript:if(jumptologin>1)alert('$maintxt{'35'}');jumptologin++;window.scrollTo(0,10000);document.loginform.username.focus();" : "$scripturl?action=login$sesredir") . qq~" title="$img_txt{'34'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'34'}$tabfill</a></span>~;
		if ($regtype) {
			$tab{'register'} = qq~<span |><a href="$scripturl?action=register" title="$img_txt{'97'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'97'}$tabfill</a></span>~;
		}
		if ($PMenableGuestButton && $PM_level > 0 && $PMenableBm_level > 0) {
			$tab{'guestpm'} = qq~<span |><a href="$scripturl?action=guestpm" title="$img_txt{'pmadmin'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'pmadmin'}$tabfill</a></span>~;
		}
	} else {
		$tab{'mycenter'} = qq~<span |><a href="$scripturl?action=mycenter" title="$img_txt{'mycenter'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'mycenter'}$tabfill</a></span>~;
		$tab{'logout'} = qq~<span |><a href="$scripturl?action=logout" title="$img_txt{'108'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'108'}$tabfill</a></span>~;
	}
	# EventCal START
	if ($Show_EventButton == 2 || (!$iamguest && $Show_EventButton == 1)) {
		$tab{'eventcal'} = qq~<span |><a href="$scripturl?action=get_cal;calshow=1" title="$img_txt{'eventcal'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'eventcal'}$tabfill</a></span>~;
	}
	if ($Show_BirthdayButton == 2 || (!$iamguest && $Show_BirthdayButton == 1)) {
		$tab{'birthdaylist'} = qq~<span |><a href="$scripturl?action=cal_birthdaylist" title="$img_txt{'birthdaylist'}" style="padding: 3px 0 4px 0;">$tabfill$img_txt{'birthdaylist'}$tabfill</a></span>~;
	}
	# EventCal END

	# Advanced Tabs starts here 
	for (my $i = 0; $i < @AdvancedTabs; $i++) {
		if ($AdvancedTabs[$i] =~ /\|/) {
			my ($tab_key,$tmptab_url, $isaction, $username_req, $tab_access, $tab_newwin, $exttab_url) = split(/\|/, $AdvancedTabs[$i]);
			if (!$tab_access || ($tab_access < 2 && !$iamguest) || ($tab_access < 3 && $iamgmod) || $iamadmin) {
				if ($tmptab_url == 1) { $tab_url = $scripturl; }
				elsif ($tmptab_url == 2) { $tab_url = qq~$boardurl/AdminIndex.$yyaext~; }
				else { $tab_url = $tmptab_url; }
				if ($isaction) { $tab_url .= qq~?action=$tab_key~; }
				if ($username_req) { $tab_url .= qq~;username=$useraccount{$username}~; }
				if ($exttab_url) { $tab_url .= qq~;$exttab_url~; }
				my $newwin = $tab_newwin ? qq~ target="_blank"~ : "";
				&GetTabtxt unless $tab_lang;
				#$tab{$tab_key} = qq~<span |><a href="$tab_url"$newwin title="$tabtxt{$tab_key}" style="padding: 3px 0 4px 0;">$tabfill $tabtxt{$tab_key} $tabfill</a></span>~;
				$yytabmenu .= qq~<span ~ . ($AdvancedTabs[$i] eq $tmpaction ? qq~class="selected"~ : "") . qq~><a href="$tab_url"$newwin title="$tabtxt{$tab_key}" style="padding: 3px 0 4px 0;">$tabfill $tabtxt{$tab_key} $tabfill</a></span>$tabsep~;
			}
		} elsif ($tab{$AdvancedTabs[$i]}) {
			my ($first, $last) = split(/\|/, $tab{$AdvancedTabs[$i]});
			$yytabmenu .= $first . (($AdvancedTabs[$i] eq $tmpaction && $last) ? qq~class="selected"~ : "") . $last . $tabsep;
		}
	}

	if ($iamadmin) {
		my ($seladdtab, $seledittab);
		if ($GLOBAL::ACTION eq "addtab") { $seladdtab = qq~class="selected"~; }
		elsif ($GLOBAL::ACTION eq "edittab") { $seledittab = qq~class="selected"~; }
		$yytabadd = qq~<div style="float: right; width: 100px; height: 21px; text-align: right;">~;
		$yytabadd .= qq~$tabsep<span $seladdtab><a href="$scripturl?action=addtab" title="$tabmenu_txt{'newtab'}" style="padding: 2px 0;">$tabfill<img src="$imagesdir/tabadd.gif" height="23" width="20" border="0" alt="$tabmenu_txt{'newtab'}" title="$tabmenu_txt{'newtab'}" />$tabfill</a></span>$tabsep~;
		$yytabadd .= qq~<span $seledittab><a href="$scripturl?action=edittab" title="$tabmenu_txt{'edittab'}" style="padding: 2px 0;">$tabfill<img src="$imagesdir/tabedit.gif" height="23" width="20" border="0" alt="$tabmenu_txt{'edittab'}" title="$tabmenu_txt{'edittab'}" />$tabfill</a></span>$tabsep~;
		$yytabadd .= qq~</div>~;
	} else {
		$yytabadd = qq~&nbsp;~;
	}
}

sub GetTabtxt {
	$tab_lang = $language ? $language : $lang;
	return if %tabtxt = map /(.*)\t(.*)/, &read_DBorFILE(1,'',"$langdir/$tab_lang",'tabtext','txt');
	if (%tabtxt = map /(.*)\t(.*)/, &read_DBorFILE(1,'',"$langdir/English",'tabtext','txt')) {
		&write_DBorFILE(0,'',"$langdir/$tab_lang",'tabtext','txt',(map "$_\t$tabtxt{$_}\n", keys %tabtxt));
	}
}

1;
