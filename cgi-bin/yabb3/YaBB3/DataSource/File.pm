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

# we've bastardized Tim Bunce's DBI::SQL::Nano for our evil purposes
# sorry!
use YaBB3::DataSource::sql_nano;

(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;

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

sub initialize { }

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
