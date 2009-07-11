#########################################################
#                                                       #
#        WELCOME TO YABB 2.4 UPDATE-RELEASE             #
#                                                       #
#########################################################


*********************************************************
PLEASE READ THE FOLLOWING IMPORTANT INFORMATION
*********************************************************

	This is the latest fully-supported release!
	It was released on April 12th, 2009.

	This is the UPDATE-PACKAGE for updates from YaBB 2.3/2.3.1 to 2.4
	If you don't have YaBB 2.3 or 2.3.1 installed on your server,
	use the package with the full version!!!


*********************************************************
INSTALLATION NOTES FOR UPDATES FROM YABB 2.3.1 TO 2.4
*********************************************************

	1)  Set your Forum in Maintenance mode.

	2)  Make a Backup of your forum. For example with YaBBs "Backup" feature.
	    Backup at least the folders:
	    Boards, Members, Messages and Variables

	3)  Set your Browser on the "Forum Settings" page and don't close this window.
	    You need it later without logging in again!!!

	4)  Upload all files from the "YaBB_2_4_upgrade_all" folder.

	    We updated the file cgi-bin/yabb2/Variables/bots.hosts that is included in
	    "YaBB_2_4_upgrade_all". If you have adapted your own Search Engine file, we
	    recommend that you make a copy of your file and compare it later with the
	    new setting (see point 8).

	5)  CHMOD the uploaded files like the other files were set. If you don't remember,
	    look into the Quick-Guide in the full version download package.

	6)  Go back to the open window with the "Forum Settings" page in it and click
	    at the "Save" Button at the bottom of the page!

	7)  Go to the "Maintenance Controls" section and run them all from top down.

	8)  Go to "AdminCenter" and review:
	    - your settings in "Forum Settings"
	    - your settings in "Advanced Settings", especially the changed setting:
	      "Number of days after a Post is made that it will no longer show as 'new' in either the Board view or Message view."
	      which was the
	      "Number of days after that Posts read by the User are marked as New Posts again."
	      setting before.
	    - your settings in "Search Engines"


*********************************************************
INSTALLATION NOTES FOR UPDATES FROM YABB 2.3 TO 2.4
*********************************************************

	1)  Set your Forum in Maintenance mode.

	2)  Make a Backup of your forum. For example with YaBBs "Backup" feature.
	    Backup at least the folders:
	    Boards, Members, Messages and Variables

	3)  Set your Browser on the "Forum Settings" page and don't close this window.
	    You need it later without logging in again!!!

	4)  Verify the path to Perl in the shebang (#!/usr/bin/perl --) for your
	    specific server in the following files of this package and change it
	    if nessesary:
	    YaBB_2_4-upgrade/cgi-bin/yabb2/YaBB.pl
	    YaBB_2_4-upgrade/cgi-bin/yabb2/AdminIndex.pl
	    YaBB_2_4-upgrade/cgi-bin/yabb2/Admin/ModuleChecker.pl

	5)  Upload all files from the "YaBB_2_4_upgrade_all" and "YaBB_2_4_upgrade_from_2_3" folders.

	    We updated the file cgi-bin/yabb2/Variables/bots.hosts that is included in
	    "YaBB_2_4_upgrade_all". If you have adapted your own Search Engine file, we
	    recommend that you make a copy of your file and compare it later with the
	    new setting (see point 9).

	6)  CHMOD the uploaded files like the other files were set. If you don't remember,
	    look into the Quick-Guide in the full version download package.

	7)  Go back to the open window with the "Forum Settings" page in it and click
	    at the "Save" Button at the bottom of the page!

	8)  Go to the "Maintenance Controls" section and run them all from top down.

	9)  Go to "AdminCenter" and review:
	    - ALL your settings in "Forum Settings"
	    - ALL your settings in "Advanced Settings"
	    - your settings in "Search Engines"


************************** END **************************