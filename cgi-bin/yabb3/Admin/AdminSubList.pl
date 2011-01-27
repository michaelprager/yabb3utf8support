###############################################################################
# AdminSubList.pl                                                             #
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

$adminsublistplver = 'YaBB 3.0 Beta $Revision: 100 $';

%director=( # in alphabetical Order!
'addboard',"ManageBoards.pl&AddBoards",
'addboard2',"ManageBoards.pl&AddBoards2",
'addcat',"ManageCats.pl&AddCats",
'addcat2',"ManageCats.pl&AddCats2",
'addmember',"Admin.pl&AddMember",
'addmember2',"Admin.pl&AddMember2",
'addsmilies',"Smilies.pl&AddSmilies",
'admin_descision',"RegistrationLog.pl&process_registration_review",
'apr_regentry',"RegistrationLog.pl&approve_registration",
'assigned',"MemberGroups.pl&Assigned_Members",
'assigned2',"MemberGroups.pl&Assigned_Members2",
'backupsettings',"Backup.pl&backupsettings",
'backupsettings2',"Backup.pl&backupsettings2",
'boardrecount',"Maintenance.pl&AdminBoardRecount",
'boardscreen',"ManageBoards.pl&BoardScreen",
'catscreen',"ManageCats.pl&DoCats",
'clean_log',"Maintenance.pl&clean_log",
'clean_reglog',"RegistrationLog.pl&clean_reglog",
'cleanerrorlog',"ErrorLog.pl&CleanErrorLog",
'convdelete',"Admin.pl&DeleteConverterFiles",
'createcat',"ManageCats.pl&CreateCat",
'del_regentry',"RegistrationLog.pl&kill_registration",
'deleteattachment',"Attachments.pl&DeleteAttachments",
'deletebackup',"Backup.pl&deletebackup",
'deletebackup2',"Backup.pl&deletebackup2",
'deleteerror',"ErrorLog.pl&DeleteError",
'deletemail',"Admin.pl&MailList",
'deletemultimembers',"Admin.pl&DeleteMultiMembers",
'deleteoldthreads',"Admin.pl&DeleteOldMessages",
'delgroup',"MemberGroups.pl&deleteGroup",
'detailedversion',"Admin.pl&ver_detail",
'downloadbackup',"Backup.pl&downloadbackup",
'editAddGroup2',"MemberGroups.pl&editAddGroup2",
'editbots',"AdminEdit.pl&EditBots",
'editbots2',"AdminEdit.pl&EditBots2",
'editemailtemplates',"EditEmailTemplates.pl&editemailtemplates",
'editemailtemplates2',"EditEmailTemplates.pl&editemailtemplates2",
'editgroup',"MemberGroups.pl&editAddGroup",
'editgroup1',"MemberGroups.pl&editAddGroup",
'editpaths',"AdminEdit.pl&EditPaths",
'editpaths2',"AdminEdit.pl&EditPaths2",
'eventcal_set',"EventCalSet.pl&EventCalSet", #EventCal Mod
'eventcal_set2',"EventCalSet.pl&EventCalSet2", #EventCal Mod
'eventcal_set3',"EventCalSet.pl&EventCalSet3", #EventCal Mod
'emailbackup',"Backup.pl&emailbackup",
'errorlog',"ErrorLog.pl&ErrorLog",
'ext_admin',"ExtendedProfiles.pl&ext_admin", # all beginning with ext_
'ext_convert',"ExtendedProfiles.pl&ext_admin_convert", # $admindir !
'ext_create',"ExtendedProfiles.pl&ext_admin_create", # and not
'ext_edit',"ExtendedProfiles.pl&ext_admin_edit", # will be called by
'ext_edit2',"ExtendedProfiles.pl&ext_admin_edit2", # $sourcedir
'ext_reorder',"ExtendedProfiles.pl&ext_admin_reorder", # by
'gmodaccess',"AdminEdit.pl&GmodSettings",
'gmodsettings2',"AdminEdit.pl&GmodSettings2",
'helpadmin',"EditHelpCentre.pl&MainAdmin",
'helpediting',"EditHelpCentre.pl&HelpEdit",
'helpediting2',"EditHelpCentre.pl&HelpEdit2",
'helporder',"EditHelpCentre.pl&SetOrderFile",
'helpsettings2',"EditHelpCentre.pl&HelpSet2",
'ipban',"Admin.pl&ipban",
'ipban2',"Admin.pl&ipban2",
'ipban3',"Admin.pl&ipban_update",
'mailing',"MailMembers.pl&Mailing",
'mailing2',"MailMembers.pl&Mailing2",
'mailing3',"MailMembers.pl&Mailing3",
'mailinggrps',"MailMembers.pl&MailingMembers",
'mailmultimembers',"Admin.pl&DeleteMultiMembers",
'manageattachments',"Attachments.pl&Attachments",
'manageattachments2',"Attachments.pl&Attachments2",
'manageboards',"ManageBoards.pl&ManageBoards",
'managecats',"ManageBoards.pl&ManageBoards",
'membershiprecount',"Maintenance.pl&AdminMembershipRecount",
'ml',"ViewMembers.pl&Ml",
'modagreement',"AdminEdit.pl&ModifyAgreement",
'modagreement2',"AdminEdit.pl&ModifyAgreement2",
'modcss',"ManageTemplates.pl&ModifyCSS",
'modcss2',"ManageTemplates.pl&ModifyCSS2",
'modifyboard',"ManageBoards.pl&ModifyBoard",
'modifycat',"ManageCats.pl&ModifyCat",
'modifycatorder',"ManageCats.pl&ReorderCats",
'modlist',"ModList.pl&ListMods",
'modmemgr',"MemberGroups.pl&EditMemberGroups",
'modmemgr2',"MemberGroups.pl&EditMemberGroups2",
'modskin',"ManageTemplates.pl&ModifySkin",
'modskin2',"ManageTemplates.pl&ModifySkin2",
'modstyle',"ManageTemplates.pl&ModifyStyle",
'modstyle2',"ManageTemplates.pl&ModifyStyle2",
'modtemp',"ManageTemplates.pl&ModifyTemplate",
'modtemp2',"ManageTemplates.pl&ModifyTemplate2",
'newsettings',"NewSettings.pl&settings",
'newsettings2',"NewSettings.pl&settings2",
'rebuildattach',"Attachments.pl&FullRebuildAttachents",
'rebuildmemhist',"Maintenance.pl&RebuildMemHistory",
'rebuildmemlist',"Maintenance.pl&RebuildMemList",
'rebuildmesindex',"Maintenance.pl&RebuildMessageIndex",
'rebuildnotifications',"Maintenance.pl&RebuildNotifications",
'recoverbackup1',"Backup.pl&recoverbackup1",
'recoverbackup2',"Backup.pl&recoverbackup2",
'referer_control',"Admin.pl&Refcontrol",
'referer_control2',"Admin.pl&Refcontrol2",
'rej_regentry',"RegistrationLog.pl&reject_registration",
'remghostattach',"Attachments.pl&RemoveGhostAttach",
'removebigattachments',"Attachments.pl&RemoveBigAttachments",
'removeoldattachments',"Attachments.pl&RemoveOldAttachments",
'removeoldthreads',"RemoveOldTopics.pl&RemoveOldThreads",
'reorderboards',"ManageBoards.pl&ReorderBoards",
'reorderboards2',"ManageBoards.pl&ReorderBoards2",
'reordercats',"ManageCats.pl&ReorderCats",
'reordercats2',"ManageCats.pl&ReorderCats2",
'reordergroup',"MemberGroups.pl&reorderGroups",
'reordergroup2',"MemberGroups.pl&reorderGroups2",
'runbackup',"Backup.pl&runbackup",
'setcensor',"AdminEdit.pl&SetCensor",
'setcensor2',"AdminEdit.pl&SetCensor2",
'setreserve',"AdminEdit.pl&SetReserve",
'setreserve2',"AdminEdit.pl&SetReserve2",
'setup_guardian',"GuardianAdmin.pl&setup_guardian",
'setup_guardian2',"GuardianAdmin.pl&setup_guardian2",
'showclicks',"Admin.pl&ShowClickLog",
'smilieindex',"Smilies.pl&SmilieIndex",
'smiliemove',"Smilies.pl&SmilieMove",
'smilieput',"Smilies.pl&SmiliePut",
'smilies',"Smilies.pl&SmiliePanel",
'stats',"Admin.pl&FullStats",
'view_regentry',"RegistrationLog.pl&view_registration",
'view_reglog',"RegistrationLog.pl&view_reglog",
'viewmembers',"ViewMembers.pl&Ml",
);

1;