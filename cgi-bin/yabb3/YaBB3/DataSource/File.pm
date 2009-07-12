package YaBB3::DataSource;
#use strict;
###############################################################################
# DateTime.pl                                                                 #
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

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->initialize( @_ );
    return $self;
}

sub initialize {
    my $self = shift;
    die "Hash argument required YaBB3::DataSource->initialize()" if @_ % 2 == 1;
    my %args = @_;

    if (not defined $args{type} or $args{type} eq "") {
        $args{type} = "File";
    }
}

1;
