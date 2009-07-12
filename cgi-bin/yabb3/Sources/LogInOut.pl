###############################################################################
# LogInOut.pl                                                                 #
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

$loginoutplver = 'YaBB 2.4 $Revision$';
if ($GLOBAL::ACTION eq 'detailedversion') { return 1; }

if ($regcheck) { require "$sourcedir/Decoder.pl"; }
&LoadLanguage('LogInOut');

$regstyle = '';

sub Login {
	$sharedLogin_title = $loginout_txt{'34'};
	$yymain .= &sharedLogin . qq~<script type="text/javascript" language="JavaScript">
<!--
	document.loginform.username.focus();
//-->
</script>~;
	$yytitle = $loginout_txt{'34'};
	&template;
}

sub Login2 {
	&fatal_error("no_username") if ($FORM{'username'} eq "");
	&fatal_error("no_password") if ($FORM{'passwrd'}  eq "");
	$username = $FORM{'username'};
	$username =~ s/\s/_/g;
	&fatal_error("invalid_character","$loginout_txt{'35'} $loginout_txt{'241'}") if $username =~ /[^ \w\x80-\xFF\[\]\(\)#\%\+,\-\|\.:=\?\@\^]/;
	&fatal_error("only_numbers_allowed") if $FORM{'cookielength'} !~ /^[0-9]+$/;

	my $user_exists = &checkfor_DBorFILE("$memberdir/$username.vars");

	## Check if login ID is not and email address or screenname ##
	if (!$user_exists) {
		my $test_id = &MemberIndex("who_is", "$FORM{'username'}");
		if ($test_id ne "") {
			$username = $test_id;
			$user_exists = 1;
		} else {
			$username = "Guest";
			&fatal_error("bad_credentials");
		}
	}
	if (&checkfor_DBorFILE("$memberdir/$username.pre")) {
		if ($user_exists) { &delete_DBorFILE("$memberdir/$username.pre"); }
		if ($regtype == 1 || $regtype == 2) { &fatal_error('not_activated'); }
	}

	# Need to do this to get correct case of username,
	# for case insensitive systems. Can cause weird issues otherwise
	&ManageMemberinfo("load");
	my $caseright;
	foreach (keys %memberinf) {
		if ($username =~ m/\A\Q$_\E\Z/) { $caseright = 1; last; }
	}
	undef %memberinf;
	if (!$caseright || !$user_exists) {
		$username = "Guest";
		&fatal_error("bad_credentials");
	}

	&LoadUser($username);
	my $spass     = ${$uid.$username}{'password'};
	my $cryptpass = &encode_password("$FORM{'passwrd'}");

	# convert non encrypted password to MD5 crypted one
	if ($spass eq $FORM{'passwrd'} && $spass ne $cryptpass) {
		# only encrypt the password if it's not already MD5 encrypted
		# MD5 hashes in YaBB are always 22 chars long (base64)
		if (length(${$uid.$username}{'password'}) != 22) {
			${$uid.$username}{'password'} = $cryptpass;
			&UserAccount($username);
			$spass = $cryptpass;
		}
	}
	if ($spass ne $cryptpass) {
		$username = "Guest";
		&fatal_error("bad_credentials");
	}

	$iamadmin     = ${$uid.$username}{'position'} eq 'Administrator' ? 1 : 0;
	$iamgmod      = ${$uid.$username}{'position'} eq 'Global Moderator' ? 1 : 0;
	$sessionvalid = 1;
	$iamguest = 0;

	if ($maintenance && !$iamadmin) { $username = 'Guest'; &fatal_error("admin_login_only"); }
	&banning;

	if ($FORM{'cookielength'} == 1) { $ck{'len'} = 'Sunday, 17-Jan-2038 00:00:00 GMT'; }
	elsif ($FORM{'cookielength'} == 2) { $ck{'len'} = ''; }
	else { $ck{'len'} = "+$FORM{'cookielength'}m"; }
	${$uid.$username}{'session'} = &encode_password($user_ip);
	&UpdateCookie("write", $username, &encode_password($FORM{'passwrd'}), ${$uid.$username}{'session'}, "/", $ck{'len'});

	&UserAccount($username, "update", "-"); # "-" to not update 'lastonline' here
	&buildIMS($username,'load'); # isn't loaded because was Guest before
	&buildIMS($username,''); # rebuild the Members/$username.ims file on login

	if($FORM{'sredir'}) {
		$FORM{'sredir'} =~ s/\~/\=/g;
		$FORM{'sredir'} =~ s/x3B/;/g;
		$FORM{'sredir'} =~ s/search2/search/g;
		$FORM{'sredir'} = qq~?$FORM{'sredir'}~;
		$FORM{'sredir'} = '' if $FORM{'sredir'} =~ /action=register/;
	}
	$yySetLocation = qq~$scripturl$FORM{'sredir'}~;
	&redirectexit;
}

sub Logout {
	if ($username ne 'Guest') {
		&RemoveUserOnline($username); # Remove user from online log
		&UserAccount($username, "update", "lastonline");
	}

	&UpdateCookie("delete");
	$yySetLocation = $guestaccess ? $scripturl : qq~$scripturl?action=login~;
	$username = 'Guest';
	&redirectexit;
}

sub sharedLogin {
	if ($GLOBAL::ACTION eq 'login' || $maintenance) {
		$yynavigation = qq~&rsaquo; $loginout_txt{'34'}~;
		$border = qq~<div class="bordercolor" style="width: 100%; margin-bottom: 8px; margin-left: auto; margin-right: auto;">~;
		$border_with_title = qq~<div class="bordercolor" style="width: 700px; margin-bottom: 8px; margin-left: auto; margin-right: auto;">~;
		$border_bottom = qq~</div>~;
	}

	if    ($Cookie_Length == 1)    { $clsel1    = ' selected="selected"'; }
	elsif ($Cookie_Length == 2)    { $clsel2    = ' selected="selected"'; }
	elsif ($Cookie_Length == 60)   { $clsel60   = ' selected="selected"'; }
	elsif ($Cookie_Length == 180)  { $clsel180  = ' selected="selected"'; }
	elsif ($Cookie_Length == 360)  { $clsel360  = ' selected="selected"'; }
	elsif ($Cookie_Length == 480)  { $clsel480  = ' selected="selected"'; }
	elsif ($Cookie_Length == 600)  { $clsel600  = ' selected="selected"'; }
	elsif ($Cookie_Length == 720)  { $clsel720  = ' selected="selected"'; }
	elsif ($Cookie_Length == 1440) { $clsel1440 = ' selected="selected"'; }
	if ($sharedLogin_title ne "") {
		$sharedlog .= qq~
$border_with_title
<table cellpadding="4" cellspacing="1" border="0" width="100%" align="center">
	<tr><td class="titlebg" colspan="2"><b>$sharedLogin_title</b></td></tr>~;
		if ($sharedLogin_text ne "") {
			$sharedlog .= qq~
	<tr><td class="windowbg" colspan="2" align="left">$sharedLogin_text</td></tr>~;
		}
		$sharedlog .= qq~
	<tr>
		<td class="windowbg2" colspan="2" align="center" valign="middle" style="padding: 10px;">~;
	} else {
		$sharedlog .= qq~
$border
<table class="bordercolor" align="center" cellpadding="0" cellspacing="1" border="0" width="100%">
	<tr><td class="tabtitle" colspan="2" valign="middle" align="center" height="25">$loginout_txt{'34'}</td></tr>
	<tr>
		<td class="windowbg" width="5%" valign="middle" align="center"><img src="$imagesdir/login.gif" border="0" alt="" /></td>
		<td class="windowbg2" align="center" valign="middle" style="padding: 10px;">~;
	}
	$sharedlog .= qq~
			<form name="loginform" action="$scripturl?action=login2" method="post">
				<input type="hidden" name="sredir" value="$INFO{'sesredir'}" />
				<div style="width: 600px;">
					<span style="float: left; width: 50%; text-align: left; margin-bottom: 5px;">
						<label for="username">$loginout_txt{'35'}</label>:<br />
						<input type="text" name="username" id="username" size="30" maxlength="100" style="width: 285px;" tabindex="1"$regstyle />
					</span>
					<span style="float: left; width: 23%; text-align: center; margin-bottom: 5px;">
						&nbsp;
					</span>
					<span style="float: left; width: 27%; text-align: right; margin-bottom: 5px;">
						&nbsp;<br />
						<input type="button" value="$maintxt{'97'}" style="width: 160px;~ . ($regtype ? "" : " visibility:hidden") . qq~" onclick="location.href='$scripturl?action=register'" tabindex="6" class="button" />
					</span>
				</div>
				<div style="width: 600px;">
					<span style="float: left; width: 29%; text-align: left; margin-bottom: 5px;">
						<label for="passwrd">$loginout_txt{'36'}</label>:<br />
						<input type="password" name="passwrd" id="passwrd" size="15" maxlength="30" style="width: 110px;" tabindex="2" onkeypress="capsLock(event,'shared_login')" />
					</span>
					<span style="float: left; width: 21%; text-align: left; margin-bottom: 5px;">
						<label for="cookielength">$loginout_txt{'497'}</label>:<br />
						<select name="cookielength" id="cookielength" style="width: 117px;" tabindex="3">
						<option value="2"$clsel2>$loginout_txt{'497d'}</option>
						<option value="1"$clsel1>$loginout_txt{'497c'}</option>
						<option value="60"$clsel60>1 $loginout_txt{'497a'}</option>
						<option value="180"$clsel180>3 $loginout_txt{'497b'}</option>
						<option value="360"$clsel360>6 $loginout_txt{'497b'}</option>
						<option value="480"$clsel480>8 $loginout_txt{'497b'}</option>
						<option value="600"$clsel600>10 $loginout_txt{'497b'}</option>
						<option value="720"$clsel720>12 $loginout_txt{'497b'}</option>
						<option value="1440"$clsel1440>24 $loginout_txt{'497b'}</option>
						</select>
					</span>
					<span style="float: left; width: 23%; text-align: center; margin-bottom: 5px;">
						&nbsp;<br />
						<input type="submit" value="$loginout_txt{'34'}" tabindex="4" accesskey="l" style="width: 100px;" class="button" />
					</span>
					<span style="float: left; width: 27%; text-align: right; margin-bottom: 5px;">
						&nbsp;<br />
						<input type="button" value="$loginout_txt{'315'}" style="width: 160px;" onclick="location.href='$scripturl?action=reminder'" tabindex="5" class="button" />
					</span>
					<br /><br />
				</div>
				<div style="width: 600px; text-align: left; color: red; font-weight: bold; display: none" id="shared_login">$loginout_txt{'capslock'}</div>
				<div style="width: 600px; text-align: left; color: red; font-weight: bold; display: none" id="shared_login_char">$loginout_txt{'wrong_char'}: <span id="shared_login_character">&nbsp;</span></div>
			</form>
		</td>
	</tr>
</table>
$border_bottom
~;

	$loginform = 1;
	$sharedLogin_title = '';
	$sharedLogin_text = '';
	return $sharedlog;
}

sub Reminder {
	$yymain .= qq~<br /><br />
<form action="$scripturl?action=reminder2" method="post">
<table border="0" width="400" cellspacing="1" cellpadding="3" align="center" class="bordercolor">
	<tr>
	<td class="titlebg">
	<span class="text1"><b>$mbname $loginout_txt{'36'} $loginout_txt{'194'}</b></span>
	</td>
	</tr><tr>
	<td class="windowbg">
	<label for="user"><span class="text1"><b>$loginout_txt{'35'}:</b></span></label>
	<input type="text" name="user" id="user" $regstyle />
	</td>
	</tr>
~;

	if ($regcheck) {
		&validation_code;
		$yymain .= qq~
	<tr>
	<td class="windowbg">
	<label for="verification"><span class="text1"><b>$floodtxt{'1'}: </b></span>
	$showcheck
	<br /><span class="small">$floodtxt{'casewarning'}</span></label>
	</td>
	</tr><tr>
	<td class="windowbg">
	<label for="verification"><span class="text1"><b>$floodtxt{'3'}: </b></span></label>
	<span class="text1"><input type="text" maxlength="30" name="verification" id="verification" size="20" /></span>
	</td>
	</tr>
~;
	}
	$yymain .= qq~
	<tr>
	<td align="center" class="windowbg">
	<input type="submit" value="$loginout_txt{'339'}" class="button" />
	</td>
	</tr>
</table>
</form>
<br /><br />
~;

	$yytitle = $loginout_txt{'669'};
	$yynavigation = qq~&rsaquo; $loginout_txt{'669'}~;
	&template;
}

sub Reminder2 {
	# generate random ID for password reset.
	my $randid = &keygen(8,"A");

	if ($regcheck) {
		&validation_check($FORM{'verification'});
	}

	my $user = $FORM{'user'};
	$user =~ s/\s/_/g;

	if (!&checkfor_DBorFILE("$memberdir/$user.vars")) {
		my $test_id = &MemberIndex("who_is", $user);
		if ($test_id) { $user = $test_id; }
		else { &fatal_error("bad_credentials"); }
	}

	# Fix to make it load in their own language
	&LoadUser($user);
	&fatal_error("corrupt_member_file") if !${$uid.$user}{'email'};

	$username = $user;
	&WhatLanguage;
	&LoadLanguage('LogInOut');
	&LoadLanguage('Email');
	undef $username;

	$userfound = 0;

	if (-e "$memberdir/forgotten.passes") {
		require "$memberdir/forgotten.passes";
	}
	if (exists $pass{$user}) { delete $pass{$user}; }
	$pass{"$user"} = $randid;

	my @temp;
	while (($key, $value) = each(%pass)) {
		push(@temp, qq~\$pass{"$key"} = '$value';\n~);
	}
	&write_DBorFILE(0,'',$memberdir,'forgotten','passes',(@temp,"\n1;"));

	$subject = "$loginout_txt{'36'} $mbname: ${$uid.$user}{'realname'}";
	if($do_scramble_id){$cryptusername = &cloak($user);} else {$cryptusername = $user; }
	require "$sourcedir/Mailer.pl";
	&LoadLanguage('Email');
	my $message = &template_email($passwordreminderemail, {'displayname' => ${$uid.$user}{'realname'}, 'cryptusername' => $cryptusername, 'remindercode' => $randid});
	&sendmail(${$uid.$user}{'email'}, $subject, $message);

	$yymain .= qq~<br /><br />
<table border="0" width="400" cellspacing="1" cellpadding="3" align="center" class="bordercolor">
	<tr>
	<td class="titlebg">
	<span class="text1"><b>$mbname $loginout_txt{'36'} $loginout_txt{'194'}</b></span>
	</td>
	</tr><tr>
 	<td class="windowbg" align="center">
	<b>$loginout_txt{'192'} $FORM{'user'}</b></td>
      </tr>
</table>
<br /><p align="center"><a href="$scripturl">$loginout_txt{'193'}</a></p><br />
~;
	$yytitle = "$loginout_txt{'669'}";
	&template;
}

sub Reminder3 {
	$id   = $INFO{'ID'};
	if($do_scramble_id){$user = &decloak($INFO{'user'});} else { $user = $INFO{'user'};}

	if ($id !~ /[a-zA-Z0-9]+/) { &fatal_error("invalid_character","ID $loginout_txt{'241'}"); }
	if ($user =~ /[^\w#\%\+\-\.\@\^]/) { &fatal_error("invalid_character","User $loginout_txt{'241'}"); }

	# generate a new random password as the old one is one-way encrypted.
	@chararray = qw(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
	my $newpassword;
	for (my $i; $i < 8; $i++) {
		$newpassword .= $chararray[int(rand(61))];
	}

	# load old userdata
	&LoadUser($user);

	# update forgotten passwords database
	require "$memberdir/forgotten.passes";
	if ($pass{$user} ne $id) { &fatal_error("wrong_id"); }
	delete $pass{$user};

	my @temp;
	while (($key, $value) = each(%pass)) {
		push(@temp, qq~\$pass{"$key"} = '$value';\n~);
	}
	&write_DBorFILE(0,'',$memberdir,'forgotten','passes',(@temp,"\n1;"));

	# add newly generated password to user data
	${$uid.$user}{'password'} = &encode_password($newpassword);
	&UserAccount($user, "update");

	$FORM{'username'} = $user;
	$FORM{'passwrd'} = $newpassword;
	$FORM{'cookielength'} = 10;
	$FORM{'sredir'} = qq*action~profileCheck2;redir~myprofile;username~$INFO{'user'};passwrd~$newpassword;newpassword~1*;
	&Login2;
}

sub InMaintenance {
	if ($maintenancetext ne "") { $maintxt{'157'} = $maintenancetext; }
	$sharedLogin_title = "$maintxt{'114'}";
	$sharedLogin_text  = "<b>$maintxt{'156'}</b><br />$maintxt{'157'}";
	$yymain .= &sharedLogin;
	$yytitle = "$maintxt{'155'}";
	&template;
}

1;
