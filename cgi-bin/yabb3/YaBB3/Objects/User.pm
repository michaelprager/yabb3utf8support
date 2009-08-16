###############################################################################
# YaBB3::Objects::User                                                        #
# YaBB3::Objects::UserData                                                    #
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

{
    package YaBB3::Objects::User;
    use strict;

    my %_ucache;

    sub new {
        my $class = shift;
        my $self = {};
        bless $self, $class;
        return $self;
    }

    sub mass_load {
        my ($self, @userids) = @_;
        my @to_load = grep {not exists $_ucache{$_}} @userids;

        for my $userid (@to_load) {
        # load them
        # get basic user settings
        # get user permissions
        # make the users into objects
            my $data = {
                settings => {},
                perms    => {},
            };
            $_ucache{$userid} = YaBB3::Objects::UserData->new($data);
        }

        return { @_ucache{@userids} };
    }

    sub load {
        my ($self, $userid) = @_;
        if (exists $_ucache{$userid}) {
            return $_ucache{$userid};
        }
        else {
            # do stuff
        }
    }
}

{
    package YaBB3::Objects::UserData;
    use strict;

    sub new {
        my $class   = shift;
        my $data    = shift;
        my $self    = defined $data ? $data : {};
        bless $self, $class;
        return $self;
    }

    sub get_setting {
        return $_[0]->{settings}{$_[1]};
    }

    sub get_extinfo {
        my ($self, $setting) = @_;
        if (not exists $self->{extended}{$setting}) {
            # get extended settings from db
        }
        return $self->{extended}{$setting};
    }

    sub can {
        return $_[0]->{perms}{$_[1]};
    }

    sub is_admin {
        return $_[0]->{perms}{is_admin};
    }

    sub set_setting {
        return $_[0]->{settings}{$_[1]} = $_[2];
    }

    sub set_extinfo {
        return $_[0]->{extinfo}{$_[1]} = $_[2];
    }

    sub set_permission {
        return $_[0]->{perms}{$_[1]} = $_[2];
    }

    sub store {
        my ($self) = @_;
        # save user back to db
    }
}

1;
