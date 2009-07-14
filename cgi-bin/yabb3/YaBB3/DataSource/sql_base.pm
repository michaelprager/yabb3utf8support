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
# Software by:  The YaBB Development Team
#               with assistance from the YaBB community.
# Sponsored by: Xnull Internet Media, Inc. - http://www.ximinc.com
#               Your source for web hosting, web design, and domains.
###############################################################################
#
# Copyright (c) 2009 Matthew Siegman
# This module has been released by Mr. Siegman for use by the YaBB project. It
# may not be redistributed outside of the YaBB project without express consent
# from Mr. Siegman.
#
###############################################################################
#
# $Id$
#

(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;

=pod

=head1 NAME

YaBB3::DataSource::sql_base - Datasource base class for SQL-like backends

=head1 SYNOPSIS

=head1 DESCRIPTION


=head1 FUNCTIONS
=cut

use DBI;
use SQL::Abstract;

=head2 new(option => 'value')

The C<new()> functions takes configuration values for the object. These
options include:

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
=cut
sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    carp "YaBB3::DataSource object not properly initialized: odd number of args"
        if @_ % 2 == 1;
    my %args = @_;

    croak "Database must be specified" unless defined $args{database};

    $self->{abs}        = SQL::Abstract->new;
    $self->{config}     = \%args;
    $self->{connected}  = 0;

    if ( not defined $args{db_type} or $args{db_type} eq "") {
        $self->{config}->{db_type}  = undef;
        $self->{config}->{user}     = undef;
        $self->{config}->{password} = undef;
    }
    else {
        if (not defined $args{user} or $args{user} eq "") {
            $self->{config}->{user} = $self->{config}->{database};
        }
    }

    # subclasses should override initialize
    $self->initialize(\%args);
    return $self;
}

=head2 initialize($arg_ref)

This method is empty and is designed to be overriden by a subclass. It is run
just before C<new()> returns. It is passed a hashref to the arguments passed
to C<new()>.

=cut
sub initialize { }


=head2 connect()

This method connects to the database using DBI. It does it's best to build a
dsn, but if you are supporting a weird database it may get it wrong.

When overriding this method, you must ensure the following:
=over
=item $self->{dbh} contains a handle to the database
=item $self->{connected} is set to one on succesful connection
=back

=cut

sub connect {
    my $self = shift;
    return if( $self->{connected} );
    die "db_type not set!" if not defined $self->{config}{db_type};
    my $dsn = "";
    if ($self->{config}->{db_type} eq "SQLite") {
        $dsn = "dbi:SQLite:dbname=$self->{config}->{database}";
    }
    else {
        $dsn = "dbi:$self->{config}->{db_type}:database="
              ."$self->{config}->{database}";
    }
    $self->{dbh} = DBI->connect($dsn,
        $self->{config}->{user}, $self->{config}->{password})
        or croak "Error connecting to database! $DBI::errstr";
    $self->{connected} = 1;
}

=head2 get_data(%arguments)

This performs a select query. The arguments are as follows:

=over
=item table (required)

This indicates which database table to query.

=item data_type (required)

This indicates how the data will be returned. It may be one of the following
types:

=over
=item HASH

Will return a hash of hashrefs. See key_col for information on the indexes.

=item ARRAY

Will return an arrayref of hashrefs containing the data.

=item ROW

Will return a hashref containing the data from the first row returned.

=back

=item key_col

If the return type is HASH, this can be set to the name of a column to have
the hash keys come from a column. Otherwise, it will just be a sequentially
indexed.

=item columns

This is an arrayref containing which columns to select from the database.

=item where

This is the where clause. It is processed by L<SQL::Abstract> to turn it into
SQL. For more information on how it works, please look at the L<SQL::Abstract>
documentation.

=item order

The order that the database should return values in. Please see
L<SQL::Abstract> for information on how it is processed.

=item limit

This adds a limit to the number of records returned. It is interpolated into
the query.

=cut

sub get_data {
    my $self = shift;
    croak "Error: odd number of arguments" if @_ % 2 == 1;
    my %args = @_;

    croak "Table and data type must be passed to get_data"
        if(not defined $args{table} or not defined $args{data_type});

    # return value if defined, default otherwise
    my $def_or = sub { return $_[0] if defined $_[0]; return $_[1]; };

    my ($stmt, @bind) = $self->{abs}->select(
        $args{table},
        $def_or->($args{columns},'*'),
        $def_or->($args{where},  undef), #where is ignored if undef
        $def_or->($args{order},  0),     #order is ignoed is 0
    );

    if (defined $args{limit} and $args{limit} ne "") {
        $stmt .= " LIMIT $args{limit}";
    }

    $self->connect;
    my $sth = $self->{dbh}->prepare($stmt);
    if (not defined $sth) {
        croak "Invalid Statement Handler, check your table name\n" ;
    }
    $sth->execute(@bind);

    if ($args{data_type} eq "HASH") {
        if (defined $args{key_col}) {
            return $sth->fetchall_hashref($args{key_col});
        }
        else {
            my $i = 0;
            my  $hr;
            while(defined(my $row = $sth->fetchrow_hashref())) {
                $hr->{$i} = $row;
                $i++;
            }
            return $hr;
        }
    }
    elsif ($args{data_type} eq "ARRAY") {
        return $sth->fetchall_arrayref({});
    }
    elsif ($args{data_type} eq "ROW") {
        return $sth->fetchrow_hashref();
    }
    else {
        carp "Do not know how to return results. Returning $sth";
        return $sth;
    }
}

=head2 insert(%args)

This method inserts a record into the database. It takes the following
arguments, both are required:

=over

=item table

Indicates the affected table

=item data

Is a hashref containing data to insert. The keys should match the column names
and the values should contain the data to insert.

=back

=cut

sub insert {
    my $self = shift;
    croak "Error: odd number of arguments" if @_ % 2 == 1;
    my %args = @_;

    croak "Table and data must be passed to insert"
        if(not defined $args{table} or not defined $args{data});

    my ($stmt, @bind) = $self->{abs}->insert( $args{table}, $args{data} );

    $self->connect;
    my $sth = $self->{dbh}->prepare($stmt);
    $sth->execute(@bind)
        or croak "Error inserting data! $DBI::errstr\n";

    return $self->{dbh}->last_insert_id(undef, undef, $args{table}, undef);
}

sub delete {
    my $self = shift;
    croak "Error: odd number of arguments" if @_ % 2 == 1;
    my %args = @_;

    croak "Table and where clause must be passed to insert"
        if(not defined $args{table} or not defined $args{where});

    my ($stmt, @bind) = $self->{abs}->delete( $args{table}, $args{where} );

    $self->connect;
    my $sth = $self->{dbh}->prepare($stmt);
    $sth->execute(@bind);

    return $sth->rows;
}

sub update {
    my $self = shift;
    croak "Error: odd number of arguments" if @_ % 2 == 1;
    my %args = @_;

    croak "Table, data and where clause must be passed to insert"
        if(not defined $args{table} or not defined $args{data}
            or not defined $args{where});

    my ($stmt, @bind) =
        $self->{abs}->update( $args{table}, $args{data}, $args{where} );

    $self->connect;
    my $sth = $self->{dbh}->prepare($stmt);
    $sth->execute(@bind);

    return $sth->rows;
}

# will write code to avoid needing to do this in the future
sub get_dbh {
    my $self = shift;
    unless( $self->{connected} ) {
        $self->connect();
    }
    return $_[0]->{dbh} if $self->{connected};
}

1;
