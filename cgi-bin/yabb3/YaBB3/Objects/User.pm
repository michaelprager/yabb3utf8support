package YaBB3::Objects::User;
use strict;
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

my @USER_FIELDS = 
qw/ id         username   password    name        email     signature
    registered posts      last_online last_post   time_zone time_format
    avatar     customtext lang        permissions flags /;
my @FIELD_MAP{@USER_FIELDS} = @USER_FIELDS;
my %RESERVED = (
    id       => 'id',
    username => 'username', 
    password => 'password',
);

sub new {
    my $class = shift;
    die "Hash required when calling YaBB3::Objects::User->new()" if @_%2 == 1;

    my $args = { @_ };
    die "userid argument must be set!" if (not defined $args->{userid});
    my $userid = $args->{userid};

    my $self = {
        id => $args->{userid},
#        args = { @_ },
    };

    bless $self, $class;
    return $self;
}

# make a new user, also a constructor
sub create {
}

####################

sub load {
    my $self = shift;

    my $fields = join ',', @user_fields;
    my $sth = $GLOBAL::DS->do_query( 
        "SELECT $fields FROM {Users} WHERE id = ?", 
        [$self->{id}]);
    my $row = $sth->fetch;

    # LANG
    die "Unknown User" if not defined $row;

    my %data;
    @data{@user_fields} = @$row;
    $self->{data} = \%data;
}

sub get {
    my ($self, $attr) = @_;

    # extended attr.
    if (not exists $FIELD_MAP{$attr}) {
        get_attr_grp($attr);
        return $self->{ext}{$attr};
    }
    else {
        return defined $attr ? $self->{data}{$attr} : $self->{data};
    }
}

sub set {
    my ($self, $attr, $val) = @_;

    if (not exists $FIELD_MAP{$attr}) {
        # already in DB ?
        if (exists $self->{ext}{$attr}) {
            $GLOBAL::DS->do_query(
                "UPDATE {UsersExtendedInfo} SET fieldvalue = ? WHERE ufid = ?", 
                [$val, $self->{userid}.$attr]);
        }
        else {
            $GLOBAL::DS->do_query(
                "INSERT INTO {UsersExtendedInfo} "
               ."(ufid, userid, fieldname, fieldvalue) VALUES (?,?,?,?)"
                [$self->{userid}.$attr, $self->{userid}, $attr, $val]);
        }
        $self->{ext}{$attr} = $val;
    }
    else {
        if (exists $RESERVED{$attr}) {
            #LANG
            die "Cannot use ->set on '$RESERVED{$attr}'";
        }
        $GLOBAL::DS->do_query(
            "UPDATE {Users} SET $FIELD_MAP{$attr} = ? WHERE id = ?", 
            [$val, $self->{userid}]);
        $self->{data}{$attr} = $val;
    }
}

sub change_password {
    my ($self, $old_password, $new_password) = @_;
    if ($self->check_password($old_password)) {
        _update_db_password($self->{userid}, $self->{data}{username}, $new_password);
    }
    else {
    }
}

sub check_password {
    my ($self, $password) = @_;

    my $correct = generate_password($self->{data}{username}, $password);
    if ($self->{data}{password} eq $correct) {
        return 1;
    }
    else {
        # backwards compatibility
        require Digest::MD5;
        if ($self->{data}{password} eq Digest::MD5::md5_base64($password)) {
            _update_db_password($self->{userid}, $self->{data}{username}, $password);
            return 1;
        }
        else {
            return 0;
        }
    }
}

sub is_admin {
}

sub is_moderator {
}

sub is_member {
}

# MD5 sucks, but it's sufficient. If the NSA wants to use YaBB, we can swap it
# out for SHA-2 or something. MD5 is still the most widely hosted Digest
# module. Crypto in pure Perl sucks.
sub generate_password {
    my ($user, $pass) = @_;

    require Digest::MD5;

    my $salt = substr $pass, 0, 2;
    return Digest::MD5::md5_base64( $user.$salt.$pass );
}

sub _update_db_password {
    my ($uid, $uname, $pass) = @_;

    my $newpass = generate_password($uname, $pass);
    $GLOBAL::DS->do_query(
        "UPDATE {Users} SET password = ? WHERE id = ?",
        [$newpass, $uid]);
}

1;
