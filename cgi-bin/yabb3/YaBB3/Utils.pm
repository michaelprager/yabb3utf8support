package YaBB3::Utils;
use strict;

###############################################################################
# Utils.pl                                                                    #
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

BEGIN {
    use Exporter ();

    @YaBB3::Utils::ISA      = qw( Exporter );

    # I know, export by default is "bad". Utility functions should be easy to
    # call, and sometimes override the core functions. This is just a
    # convenient place to stash them all at.
    @YaBB3::Utils::EXPORT   = qw( die );
}

sub die {
    #TODO: logging?

    CORE::die(@_,"\n\n");
}

1;
