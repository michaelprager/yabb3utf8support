package YaBB3::DataSource::File;
use strict;

###############################################################################
# YaBB3::DataSource::File    
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

use SQL::Statement;

(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    carp "YaBB3::DataSource object not properly initialized: odd number of args"
        if @_ % 2 == 1;
    my %args = @_;

    croak "Database must be specified" unless defined $args{database};

    $self->{config}     = \%args;

    # subclasses should override initialize
    $self->initialize(\%args);
    return $self;
}

sub initialize { }


1;
