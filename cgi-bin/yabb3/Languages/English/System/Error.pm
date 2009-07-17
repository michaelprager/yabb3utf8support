###############################################################################
# System/Error.pm (Error text definitions)
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
#

(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;

%LANG::ERROR = (
    INVALID_LANGUAGE => "Language Error: Invalid Language Module Requested",
);

#TODO
%error_txt = (
## General Errors ##
'error_occurred'                => "An Error Has Occurred!",
'untrapped'                     => "Untrapped Error",
'cannot_open'                   => "Unable to open",
'cannot_open_dir'               => "Can't open directory",
'cannot_open_language'          => "Can't find required language file. Please inform the administrator about this problem.",
'cannot_delete'                 => "Unable to delete",
'not_completed'                 => "An error has occurred and this action could not be completed. Sorry for the inconvenience.",
'not_logged_in'                 => "To perform this action you must be logged in. If you don't have an account yet, please register.",
'logged_in_already'             => "You are logged in already with the username: ",
'no_access'                     => "You are not allowed to access this section.",
'not_found'                     => "The information you are trying to access is not available to you.",
'not_allowed'                   => "You are not allowed to perform that action",
'only_numbers_allowed'          => "This field only accepts numbers from 0-9",
'user_not_exist'                => "User does not exist",
'members_only'                  => "Sorry, this service is for registered members only!",
'email_no_access'               => "Sorry, you are not allowed to access this users email address!",
'no_subject'                    => "The Subject field was not filled out. It is required.",
'no_message'                    => "The Message Body was not filled out. It is required.",
'no_recipient'                  => "The Recipient field was not filled out. It is required",
'no_email'                      => "The Email field was not filled out. It is required.",
'no_name'                       => "The Name field was not filled out. It is required.",
#'no_ip'                         => "IP not found, please change \$user_ip in $lang",
'no_username'                   => "The User ID field was not filled out. It is required.",
'no_password'                   => "Password field is empty",
'no_action'                     => "No action specified but",
'no_info'                       => "No info specified in url",
'password_mismatch'             => "Passwords aren't the same!",
'bad_credentials'               => "Username / Password mismatch. <br />The Username you specified does not exist or you entered a wrong password.",
'invalid_character'             => "There is an invalid character detected in the",
'invalid_email'                 => "Please enter a valid e-mail address.",
'invalid_picture'               => "Invalid Board Picture Input.",
'no_secret_answer'              => "You need to fill out an answer to the question asked",
'no_verification_code'          => "The Verification code was not filled out. It is required.",
'wrong_verification_code'       => "The Verification code was not the same as the image presented on screen, please go back, refresh (hit F5 on most browsers) and try again.",
'invalid_verification_code'     => "Verification code contains invalid characters. Only a-z and 0-9 are valid",
'form_spoofing'                 => "<b>ALERT!!</b> Form Spoofing Detected coming from IP address:",
'post_flooding'                 => "The last POST request from your IP was less than",
'denial_of_service'             => "The last POST request did output an error message: ",
#'speed_alert'                   => "Posting this fast is considered spamming, you are warned!<br />You are only allowed <b>$spam_hits_left_count</b> more attempt(s) after which you will be banned as spammer!",
#'tsc_alert'                     => "One of form fields contains text which is considered SPAM, you are warned!<br />You are only allowed <b>$spam_hits_left_count</b> more attempt(s) after which you will be banned as spammer!",
#'speedpostban'                  => "You are currently banned from posting due to possible spamming!<br />After <b>$detention_left</b> second(s) your ban will automatically be lifted!",
#'truncation_error'              => "Please make sure you have 'fake truncation' turned on in your Settings.pl file.<br />\$faketruncation = 1;<br />Could not truncate file",
'referer_violation'             => "This action is not allowed from an outside domain!! <br />Action is: ",
'egg'                           => "Self Destruct Sequence Started !!<br />",
'domain_not_allowed'            => "You may not register with, post as a guest or change your email address to one from the domain",
'module_missing'                => "Module(s) or functionality needed not installed on this server !!",
'low_diskspace'                 => "The available disk/hostspace is low. The forum was put to maintenance to avoid file corruption. Please notify the administrator of this error !!",
'invalid_key'                   => "Masterkey is invalid !<br />This should be a text string between 8 and 24 characters long !",
'corrupt_member_file'           => "The member data file is corrupt. Please notify the administrator of this error!",

## BoardIndex ##
'collapse_no_member'            => " You must be a member to use the collapsible/expandable categories!",
'collapse_invalid_state'        => "The state you specified was invalid. Please go back and try again",
'collapse_no_usercat'           => " User category file not found - please try refreshing the board index (back then F5).\n If you receive this message again, please inform an administrator.",

## Guardian ##
'proxy_reason'                  => "Proxy Access to this forum is denied!",
'referer_reason'                => "Access to the forum from the current url is prohibited!",
'harvester_reason'              => "This harvester is denied access to the forum!",
'request_reason'                => "The Request Method you tried to use is not allowed here!",
'string_reason'                 => "Your url contains words not allowed here!",
'clike_reason'                  => "It's useless to try to CLIKE hack this site as it does not run MySQL!",
'union_reason'                  => "It's useless to try to UNION hack this site as it does not run MySQL!",
'script_reason'                 => "You tried to use scripting in the url or form input, which is not allowed!",

## InstantMessage ##
'im_deleted'                    => "Message was already read by recipient, therefore wasn't called back!",
'im_deleted_multi'              => "At least one of the recipients has already read the Message, therefore no Message was called back!",
'im_members_only'               => "Personal Messaging is only for members",
#'im_low_postcount'              => "You are only allowed to send Personal Messages if you've reached a post count of $numposts!",
'im_spam_alert'                 => "You are trying to send a private message to too many users at once. This is being interpreted as possible spamming.",
'im_bad_users'                  => "The following user(s) could not be messaged.<br />The username(s) is/are either invalid, or they have you on their ignore list: ",
'cannot_find_draftmess'         => "Draft Message cannot be found.",
'im_folder_exists'              => "A folder with this name already exists.",

## LogInOut ##
'not_activated'                 => "Your account is not activated yet<br />Please activate it by clicking the link in the email you received!",
#'time_out'                      => "You did not activate your account within $preregspan hours!<br />As a result your pre-registration has been removed!<br />Please re-register again!",
'wrong_code'                    => "Your activation code is wrong!",
'admin_login_only'              => "Only the admin can login at the moment, because our forum is in Maintenance Mode.<br />Please try again later. Thank you!",
'wrong_id'                      => "You have an invalid ID. Please try again.",

## Mailer ##
'net_fatal'                     => "Net::SMTP fatal error",
'smtp_error'                    => "SMTP Error",
'smtp_unavail'                  => "SMTP connection could not be established",

## Post/ModifyMessage/Poll ##
'topic_locked'                  => "This topic is locked, and you are not allowed to post or modify messages.",
'time_locked'                   => "The Forum Admin has set a time limit of ",
'change_not_allowed'            => "You are not allowed to change this message",
'delete_not_allowed'            => "You are not allowed to delete this post!",
'split_splice_not_allowed'      => "You are not allowed to split or splice this topic; you must be a moderator or administrator to do this.",
'no_perm_post'                  => "You do not have permission to post new topics in this board",
'no_perm_reply'                 => "You do not have permission to reply to topics in this board",
'no_perm_poll'                  => "You do not have permission to post polls in this board",
'no_perm_att'                   => "You do not have permission to post attachments in this board",
'no_board_slash'                => "The board field does not accept / in the query string",
'no_cat_slash'                  => "The category field does not accept / in the query string",
'no_board_backslash'            => "The board field does not accept \\ in the query string",
'no_cat_backslash'              => "The category field does not accept \\ in the query string",
'no_board_topic'                => "This topic doesn't exist on this board.",
'bad_postnumber'                => "BAD post num",
'file_overwrite'                => "A file on the server already exists with that name. Please rename your file before attaching.",
'file_not_open'                 => "Could not open a new file on the server, check the paths and chmods",
'invalid_format'                => "Invalid File Format. Valid files are",
'file_too_big'                  => "Attachment is to big by approx. ",
'dir_full'                      => "This attachment causes the attachments directory to exceed it's maximum capacity by approx. ",
'file_not_uploaded'             => "Could not upload file",
'useless_post'                  => "Only spaces and line feeds is not considered a useful contribution!",
'no_question'                   => "Please supply a poll question.",
'no_options'                    => "Please provide at least 2 poll options.",
'poll_not_found'                => "The poll could not be found",
'no_vote_option'                => "Please select an option to vote for before voting!",
'locked_poll_no_delete'         => "This poll is locked so your vote could not be removed",
'locked_poll_no_count'          => "This poll is locked so your vote could not be counted",
'ip_guest_used'                 => "A guest has already used this IP address to register their vote",
'ip_member_used'                => "A member has already used this IP address to register their vote",
'voted_already'                 => "You have already voted in this poll",
'guest_taken'                   => "The username or email address given is already taken by a member.<br />Conflicting name or email: ",
'quote_too_long'                => "The message you have tried to quote is too long. Please shorten it.",
#'no_links_allowed'              => "Sorry, you are not allowed to post messages containing active links to websites or images before you have posted $minlinkpost normal messages.",

## MoveTopic ##
'move_not_allowed'              => "You are not allowed to move topics...",

## Profile ##
'invalid_password'              => "Invalid password.<br /> You have entered an incorrect password.",
'no_user_slash'                 => "The user ID field does not accept / in the query string",
'no_user_backslash'             => "The user ID field does not accept \\ in the query string",
'not_allowed_profile_change'    => "You are not allowed to change this person's profile.",
'no_profile_exists'             => "The user whose profile you are trying to view does not exist!",
'current_password_wrong'        => "Your Current Password is incorrect",
'no_admin_password'             => "You need to fill in the correct admin password to make changes to this profile.",
'password_is_userid'            => "For security reasons, you cannot use your user ID as your password.",
'name_is_userid'                => "For security reasons it is not allowed to have a Displayed Name the same as the login ID.",
'name_taken'                    => "This displayed name is already in use by another member.",
'name_censored'                 => "You have used one or more censored words in your displayed name. Please go back and change your displayed name. The word, or words that caused the problem are:",
'name_too_long'                 => "Please shorten your displayed name. It is too long.",
'invalid_birthdate'             => "Invalid input in one or more of the Birthdate fields.",
'id_reserved'                   => "The user ID you tried to register contains a reserved name! Please try another user ID. Reserved ID: ",
'name_reserved'                 => "The displayed name you tried to register contains a reserved name! Please try another displayed name. Reserved displayed name: ", #new
'cannot_kill_admin'             => "As a security feature, you cannot delete the account with user ID: ",
'email_taken'                   => "The following e-mail address is being used by a registered member already! If you feel this is a mistake, please go to the login page and use the password reminder with that address.",
'invalid_template'              => "This is not a valid template name.",
'invalid_language'              => "This is not a valid language name.",
'invalid_time_offset'           => "Time offset must be +/- and numeric!",
'invalid_postcount'             => "The 'number of posts' box can only contain digits.",
'cannot_regroup_admin'          => "The Administrator with username of 'admin' cannot be set to a different membergroup!",
'session_time_out'              => "Profile Session timed out.",

## Register ##
'registration_disabled'         => "The registration feature has been disabled on this forum.",
'no_registration_logged_in'     => "You cannot register while logged in.",
'banned'                        => "Banning Notification.",
'system_prohibited_id'          => "User ID prohibited by system",
'id_alfa_only'                  => "User ID may only contain numbers and letters (example: yabber69)",
'id_taken'                      => "The user ID you tried to register already exists.",
'id_to_long'                    => "Please shorten your User ID. It is to long.",
'realname_to_long'              => "Please shorten your Displayed Name. It is to long.",
'email_to_long'                 => "Please shorten your Email. It is to long.",
'already_preregged'             => "This user is already pre-registered!",
'email_already_preregged'       => "This Email is already pre-registered!",
'already_activated'             => "This user has already been activated!",
#'prereg_expired'                => "This user was not pre-registered or the allowed time span of $preregspan hours expired!",
'no_regagree'                   => "You cannot register unless you agree to the registration agreement.",
'no_reg_reason'                 => "Without giving a reason for applying for membership we cannot process your application.",

## Search ##
'search_disabled'               => "The search option has been disabled",
'result_too_high'               => "The requested number of results is higher then the maximum number allowed by the system",
'no_search'                     => "You must specify a search string!",
'no_search_slashes'             => "The search field does not accept / or \\ in the query string",

## SendTopic ##
'no_board_send'                 => "The board is missing from the query.",
'no_topic_send'                 => "The topic is missing from the query.",
'sendname_too_long'             => "Please shorten your name. It is too long.",

## Admin Stuff ##
'announcement_defined'          => "The forum can only have one board defined as a Global Announcement board",
'recycle_bin_defined'           => "The forum can only have one board defined as a Recycle Bin",
'board_defined'                 => "A board with this ID was already exists",
'cat_defined'                   => "A category with this ID already exists",
'no_delete_default'             => "For security reasons you are not allowed to delete or change the 'default' template.",
'invalid_template'              => "Not a valid Template Name!",
'no_group_name'                 => "Please Enter a name",
'no_post_number'                => "Please Enter a number",
'invalid_post_number'           => "Invalid post amount",
'double_group'                  => "You can not have two membergroups with the same name:",
'double_count'                  => "You can not have two post dependent groups with the same post count.",
'no_groupname_change'           => "You can not change the name of a post independent group.",
'invalid_value'                 => "You have entered an invalid value for this item: ", # NEW

## Permalinking ##
'no_board_found'                => "The board you referred to does not seem to exist (anymore).",
'no_topic_found'                => "The topic you referred to does not seem to exist (anymore).",

## buddy list ##
'self_buddy'                    => "You cannot add yourself to your own buddylist - you egomaniac!",

## advanced tabs ##
'tabext'                        => 'A tab for the same action or with the same name already excists!!',

## MemberGroups ##
'newpostdep_gmod'               => 'Sorry, Global Mods can\'t modify Postdependent users because the Maintenance->"Rebuild Memberlist" must be run after and that function is only available in Maintenance Mode, so it would deny your login!',
);

#TODO

for my $key (keys %error_txt) {
    $LANG::ERROR{$key} = $error_txt{$key};
}

1;

