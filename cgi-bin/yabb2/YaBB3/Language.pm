package YaBB3::Language;
use strict;
###############################################################################
# YaBB3/Language.pm                                                           #
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

use YaBB3::Paths;
use YaBB3::Settings;
use YaBB3::Utils;

# maps the language module names to paths in the language directory
my %file_for = (
    ERROR => "System/Error.pm",
    TIME  => "System/Time.pm",
);

LoadLanguageFile("ERROR");

#TODO
sub import {
}

# This is the only hardcoded string in the system. It has to be because
# language files may not be loaded :)
sub LoadLanguageFile {
    my ($language_module) = @_;
    if (not defined $file_for{$language_module}) {
        if (defined $LANG::ERROR{INVALID_LANGUAGE}) {
            die $LANG::ERROR{INVALID_LANGUAGE};
        }
        else {
            die "LANGUAGE ERROR: INVALID LANGUAGE MODULE REQUESTED";
        }
    }

    my $dir  = defined $PATHS::langdir ? $PATHS::langdir 
                                       : "./Languages";
    my $lang = defined $SETTINGS::Language ? $SETTINGS::Language 
                                           : "English";

    eval {
        require "$dir/$lang/$file_for{$language_module}";
    };
    if ($@) {
        if (defined $LANG::ERROR{INVALID_LANGUAGE}) {
            die $LANG::ERROR{INVALID_LANGUAGE};
        }
        else {
            die "LANGUAGE ERROR: INVALID LANGUAGE MODULE REQUESTED";
        }
    }
}

1;
