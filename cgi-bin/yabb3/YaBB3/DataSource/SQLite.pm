package YaBB3::DataSource::SQLite;
use base 'YaBB3::DataSource::sql_base';
use strict;

###############################################################################
# YaBB3::DataSource::SQLite
###############################################################################
# YaBB: Yet another Bulletin Board
# Open-Source Community Software for Webmasters
# Version:        YaBB 2.4
# Packaged:       April 12, 2009
# Distributed by: http://www.yabbforum.com
# ===========================================================================
# Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.
# Software by:  The YaBB Development Team
#               with assistance from the YaBB community.
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com
#               Your source for web hosting, web design, and domains.
###############################################################################
#
# $Id$
#

(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;


# sql_base works fine for SQLite without any changes
# see YaBB3::DataSource::sql_base for more documentation

sub initialize {
    $_[0]->{config}{db_type} = "SQLite";
}

1;
