package YaBB3::DataSource::sql_base;
use strict;

###############################################################################
# YaBB3::DataSource::sql_base
###############################################################################
# YaBB: Yet another Bulletin Board
# Open-Source Community Software for Webmasters
# Version:        YaBB 2.4
# Packaged:       April 12, 2009
# Distributed by: http://www.yabbforum.com
# ===========================================================================
# Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.     #
# Software by:  The YaBB Development Team
#               with assistance from the YaBB community.
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com
#               Your source for web hosting, web design, and domains.
###############################################################################
#
# $Id$
#

(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;

use DBI;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    die "YaBB3::DataSource object not properly initialized: odd number of args"
        if @_ % 2 == 1;
    my %args = @_;

    die "Database must be specified" unless defined $args{database};

    $self->{config}     = \%args;
    $self->{connected}  = 0;

    if (not defined $args{user} or $args{user} eq "") {
        $self->{config}->{user} = $self->{config}->{database};
    }

    # subclasses should override initialize
    $self->_initialize(\%args);
    return $self;
}

sub do_query {
    my ($self, $sql, $ph_values) = @_;
    my $sth = $self->prepare($sql);
    $sth->execute( @$ph_values );
    return $sth;
}

sub prepare {
    my ($self, $sql) = @_;
    die "EMPTY QUERY" if ($sql eq "");

    $self->_connect if not $self->{connected};

    # the statement object from DBI has a execute and fetch method. Handy, eh?
    return $self->{dbh}->prepare( $sql );
}

sub _initialize { }

sub _connect {
    my $self = shift;
    return if( $self->{connected} );
    die "db_type not set!" if not defined $self->{config}{db_type};
    my $dsn = "";
    if ($self->can('_get_dsn')) {
        $dsn = $self->_get_dsn();
    }
    else {
        $dsn = "dbi:$self->{config}->{db_type}:database="
              ."$self->{config}->{database}";
    }
    $self->{dbh} = DBI->connect($dsn,
        $self->{config}->{user}, $self->{config}->{password})
        or die "Error connecting to database! $DBI::errstr";
    $self->{connected} = 1;
}

# will write code to avoid needing to do this in the future
sub _get_dbh {
    my $self = shift;
    unless( $self->{connected} ) {
        $self->connect();
    }
    return $_[0]->{dbh} if $self->{connected};
}

1;

__END__

=pod

=head1 NAME

YaBB3::DataSource::sql_base - Datasource base class for SQL-like backends

=head1 SYNOPSIS

=head1 DESCRIPTION

Provides a base class for C<YaBB3::DataSource::*> modules that use DBI-based
sources for data

=head1 METHODS

=head2 new(option => 'value')

This functions is usually called by the YaBB3::DataSource module. It will
supply the user, password and database arguments based on the current board's
configuration.

=head3 Options

=over

=item db_type

This indicates what type of database we are connecting to. In most cases, this
is not set here and is instead initialized in the subclassed c<initialize()>
method.

=item user

This is the user to use for DB connection. It should be set by the user of the
module.

=item password

This is the password for the DB connection. It should be set by the user of
the module.

=item database

This is the name of the database to connect to. It should be set by the user
of the module.

=back

=head3 Return Value

Returns an object of the class that new was called in.

=head2 do_query( $sql, [ bind_values, ... ])

Behaves in accordance with the API defined in L<YaBB3::DataSource>

=head2 prepare( $sql )

Behaves in accordance with the API defined in L<YaBB3::DataSource>

=head1 STATEMENT HANDLERS

=head2 execute( bind_values, ... )

Behaves in accordance with the API defined in L<YaBB3::DataSource>

=head2 fetch( )

Behaves in accordance with the API defined in L<YaBB3::DataSource>

=head1 PROTECTED METHODS

These methods are for use in subclasses only and are not so be called by other
modules.

=head2 _initialize( $arg_ref )

This is not a method designed for public calling. It is for use only by this
class and it's sub-classes. (A protected method in C++ speak.)

This method is empty and is designed to be overriden by a subclass. It is run
just before C<new()> returns. It is passed a hashref to the arguments passed
to C<new()>.

=head3 Arguments

=over

=item $arg_ref

A hash reference to the hash of arguments passed into the new method.

=back

=head3 Return Value

Does not return a value.

=head2 _get_dsn( )

This method returns a DSN for calling DBI. If this method is not available a
generic DSN will be built like shown below:

  $dsn = "dbi:$self->{config}->{db_type}:database="
        ."$self->{config}->{database}";

=head3 Arguments

None

=head3

Returns a dsn usable for DBI.

=head2 _connect( )

This is not a method designed for public calling. It is for use only by this
class and it's sub-classes. (A protected method in C++ speak.)

This method connects to the database using DBI. It does it's best to build a
dsn, but if you are supporting a weird database it may get it wrong.

When overriding this method, you must ensure the following:
=over
=item $self->{dbh} contains a handle to the database
=item $self->{connected} is set to one on succesful connection
=back

=head3 Arguments

None.

=head3 Return Value

Does not return a value.

=head2 _get_dbh( )

=head3 Arguments

None.

=head3 Return Value

Returns the connected handle to DBI. Will connect if required.

=cut


=head1 REFERENCES

This following links were helpful when creating this document and may contain
further helpful information:

L<DBI>

=head1 LICENSE

This module is licensed under the same terms as YaBB.

=head1 AUTHOR

Matthew Siegman

Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.

=cut

