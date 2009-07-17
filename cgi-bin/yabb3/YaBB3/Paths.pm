package YaBB3::Paths;
use strict;

###############################################################################
# Paths.pl                                                                    #
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

# We really shouldn't do this, and by the Beta, this should be removed. We are
# only doing this because it is going to take a while to fix all the code that
# depends on yucky globals.
BEGIN {
    use Exporter ();

    @YaBB3::Paths::ISA         = qw( Exporter );

    @YaBB3::Paths::EXPORT_OK   = qw(
        $lastsaved      $lastdate       $boardurl       $boarddir   $boardsdir
        $datadir        $memberdir      $sourcedir      $admindir   $vardir
        $langdir        $helpfile       $templatesdir   $htmldir    $facesdir
        $uploaddir      $yyhtml_root    $facesurl       $uploadurl
    );

    %YaBB3::Paths::EXPORT_TAGS = ( all => [qw(
        $lastsaved      $lastdate       $boardurl       $boarddir   $boardsdir
        $datadir        $memberdir      $sourcedir      $admindir   $vardir
        $langdir        $helpfile       $templatesdir   $htmldir    $facesdir
        $uploaddir      $yyhtml_root    $facesurl       $uploadurl
    )]);
}

our ($lastsaved,    $lastdate,  $boardurl, $boarddir,  $boardsdir,   $datadir);
our ($memberdir,    $sourcedir, $admindir, $vardir,    $langdir,     $helpfile);
our ($templatesdir, $htmldir,   $facesdir, $uploaddir, $yyhtml_root, $facesurl);
our ($uploadurl);

###

$lastsaved = "";
$lastdate = "";

########## Directories ##########

$boardurl = "";  # URL of your board's folder (without trailing '/')
$boarddir = ".";                                  # The server path to the board's folder (usually can be left as '.')
$boardsdir = "./Boards";                          # Directory with board data files
$datadir = "./Messages";                          # Directory with messages
$memberdir = "./Members";                         # Directory with member files
$sourcedir = "./Sources";                         # Directory with YaBB source files
$admindir = "./Admin";                            # Directory with YaBB admin source files
$vardir = "./Variables";                          # Directory with variable files
$langdir = "./Languages";                         # Directory with Language files and folders
$helpfile = "./Help";                             # Directory with Help files and folders
$templatesdir = "./Templates";                    # Directory with template files and folders
$htmldir = ""; # Base Path for all public-html files and folders
$facesdir = ""; # Base Path for all avatar files
$uploaddir = ""; # Base Path for all attachment files

########## URL's ##########

$yyhtml_root = ""; # Base URL for all html/css files and folders
$facesurl = ""; # Base URL for all avatar files
$uploadurl = ""; # Base URL for all attachment files

# deprecated values removed, major version changes let you do that :-)

#TODO
# must go away by beta
no strict 'refs';
for my $var (qw/
        lastsaved      lastdate       boardurl       boarddir   boardsdir
        datadir        memberdir      sourcedir      admindir   vardir
        langdir        helpfile       templatesdir   htmldir    facesdir
        uploaddir      yyhtml_root    facesurl       uploadurl/) {
    eval "\$PATHS::$var = \$$var";
}

$YaBB3::Paths::DatabaseDir = "$vardir/database";
