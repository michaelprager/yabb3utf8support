###############################################################################
# YaBB3/DataSource/File.pm
# YaBB3::DataSource::File
# YaBB3::DataSource::File::st
# YaBB3::DataSource::File::Statement
# YaBB3::DataSource::File::Table
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

# Beware, ye who enter. There be dragons here.
use strict;
use DB_File;
use SQL::Parser;
use YaBB3::Paths qw( $vardir );
$YaBB3::Paths::DatabaseDir = "$vardir/database";

# check whether flock works, technique comes from DBD::File
$YaBB3::DataSource::File::can_lock = eval { flock STDOUT, 0; 1 };

###############################################################################
# I used the doc SQL::Statement::Embed and the code for DBD::File as
# references when building this to make sure I don't forget something
# important. This is kind of an important module, and screwing it up would be
# bad.
###############################################################################
package YaBB3::DataSource::File;
use strict;
use YaBB3::DataSource;

# only need one parser object, ever
my $parser = undef;

(our $VERSION = '$Revision$') =~ s~^\$ R e v i s i o n: \s (.*) \s \$$~$1~x;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    die "YaBB3::DataSource object not properly initialized: odd number of args"
        if @_ % 2 == 1;
    my %args = @_;

    die "Database must be specified" unless defined $args{database};

    $self->{config}     = \%args;

    if (not defined $parser) {
        $parser = SQL::Parser->new();
        $parser->{RaiseError} = 1;
        $parser->{PrintError} = 0;
        $parser->feature('valid_data_types', 'TEXT', 1);
        $parser->feature('valid_data_types', 'BLOB', 1);
    }

    # subclasses should override initialize
    $self->initialize(\%args);
    return $self;
}

sub initialize { }

# do_query( $sql, [ bind_values, ... ])

sub do_query {
    my ($self, $sql, $bind) = @_;
    my $sth = $self->prepare( $sql );
    $sth->execute( @$bind );
    return $sth;
}

# prepare( $sql )

sub prepare {
    my ($self, $sql) = @_;

    return _empty() if not defined $sql;

    # add a couple things that SQL::Parser/Statement don't seem to support
    $sql =~ s/(\-\-.*)$//mg; # /m makes $ match any EOL

    return _empty() if $sql eq "" or $sql =~ /\A\s*\z/ms;

    YaBB3::DataSource::parse_tables( $sql );

    if ($sql =~ /CREATE INDEX (\w+) ON (\w+) \(\s*(\w+)\s*\)/i) {
        my ($index_name, $table, $column) = ($1, $2, $3);
      #  warn "create index $index_name on table $table, using $column";
        return $self->_index_creator( $index_name, $table, $column );
    }

    my $stmt = YaBB3::DataSource::File::Statement->new($sql, $parser);


    my $sth = {
        database        => $self->{config}{database},
        stmt            => $stmt,
        params          => [],
        NUM_OF_PARAMS   => scalar( $stmt->params() ),
    };
    bless $sth, 'YaBB3::DataSource::File::st';
    return $sth;
}

sub _index_creator {
    my ($self, $index_name, $table, $column) = @_;
    my $sth = {
        database    => $self->{config}{database},
        table       => $table,
        index_name  => $index_name,
        column      => $column,
    };
    bless $sth, 'YaBB3::DataSource::File::indexmaker';
    return $sth;
}

sub _empty {
    my $empty = {};
    bless $empty, 'YaBB3::DataSource::File::empty';
    return $empty;
}

package YaBB3::DataSource::File::empty;
use strict;

sub execute { return 1; }
sub fetch {}

package YaBB3::DataSource::File::indexmaker;
use strict;

# need to have this create an index on the column
sub execute { return 1; }
sub fetch {}

package YaBB3::DataSource::File::st;
use strict;

sub execute {
    my $sth = shift;
    my $params = [ @_ ];

    $sth->finish;
    my $stmt = $sth->{stmt};

    # according to DBD::File, there is a bug in SQL::Statement if these are
    # ->params() is called more than once....
    if (not $sth->{params_checked}) {
        $sth->{params_checked} = 1;
        my $required = $stmt->params();
        my $given    = @$params;
        if ($required != $given) {
            die "$given parameters passed when $required required.";
        }
    }

    return $stmt->execute($sth, $params) || "0E0";
}

sub fetch {
    my $sth  = shift;
    my $data = $sth->{stmt}->{data};
    if (!$data or ref $data ne "ARRAY") {
        die "->fetch() called without ->execute() or with non-SELECT query.";
    }

    my $results = shift @$data;
    if (not $results) {
        $sth->finish;
        return;
    }

    return $results;
}

sub finish {
    delete $_[0]->{stmt}->{data};
    return 1;
}

package YaBB3::DataSource::File::Statement;
use strict;
use base 'SQL::Statement';
use Fcntl qw( :flock );


sub get_file {
    my ($self, $data, $table_name) = @_;

    die "No table given" if not defined $table_name;

    #name can be quoted
    $table_name =~ s/^\"//;
    $table_name =~ s/\"$//;

    die "No table given" if $table_name eq "";

    return "$YaBB3::Paths::DatabaseDir/$data->{database}/$table_name";
}

# instead of calling YaBB3::DataSource::File::Table->new, we call this one
sub open_table {
    my ($self, $data, $table_name, $create_table, $lock_mode) = @_;
    my $file_base = $self->get_file($data, $table_name);

    my $fh;#%db;

    if ($create_table) {
        if( -e $file_base ) {
            die "'$table_name' already exists.";
        }
        open $fh, '+>>', "$file_base.tbl"
            or die "Cannot create $file_base.tbl: $!";
        seek $fh, 0, 0
            or die "Seek Error: $!";
        #tie %db, "DB_File", "$file_base.tbl", ORDWR|O_CREAT, 0666, $DB_BTREE
        #    or die "Cannot create $file_base.tbl: $!";
    }
    else {
        open $fh, ($lock_mode ? "+<" : "<"), "$file_base.tbl"
            or die "Error opening $file_base.tbl: $!";
    }

    die "Could not open table: $table_name" if not $fh;

    binmode $fh;

    if ($YaBB3::DataSource::File::can_lock) {
        if ($lock_mode) {
            flock $fh, LOCK_EX
                or die "Can't lock $file_base.tbl: $!";
        }
        else {
            flock $fh, LOCK_SH
                or die "Can't lock $file_base.tbl: $!";
        }
    }

    my $table = {
        file_base       => $file_base,
        fh              => $fh,
        col_nums        => {}, # { n1 => 0, n2 => 1, ... }
        col_names       => [], # ['n1', 'n2', ...]
        first_row_pos   => tell($fh),
    };

    bless $table, 'YaBB3::DataSource::File::Table';
    $table->_get_cols if not $create_table;

    return $table;
}

###############################################################################
package YaBB3::DataSource::File::Table;
use strict;
use Fcntl qw( :flock );

sub col_names { return $_[0]->{col_names}; }
sub col_nums  { return $_[0]->{col_nums};  }
sub column_num {
    return $_[0]->{col_nums}->{uc($_[1])};
}

sub _get_cols {
    my ($self) = @_;

    my ($col_names, $col_types, $col_nums, $pk_name);

    open my $col_fh, '<', "$self->{file_base}.cols"
        or die "Could not read columns $self->{file_base}.cols: $!";
    flock $col_fh, LOCK_SH
        or die "Can't lock $self->{file_base}.cols: $!";
    my @lines = <$col_fh>;
    close $col_fh;

    for (@lines) { chomp; }

    @$col_names = split /\|/, uc($lines[0]);
    @$col_types = split /\|/, uc($lines[1]);
    $pk_name    = uc($lines[2]);

    my $num_cols = scalar @$col_names;
    for (my $i = 0; $i < $num_cols; $i++) {
        $col_nums->{$col_names->[$i]} = $i;
    }

    $self->{col_nums}      = $col_nums;
    $self->{col_names}     = $col_names;
    $self->{col_datatypes} = $col_types;
    $self->{primary_key}   = $pk_name;

    return;
}

#TODO
sub _check_pk {
}

#TODO

#sub delete_one_row {
#    my ($self, $data, $fields) = @_;
#}

#sub update_one_row {
#    my ($self, $data, $new_fields) = @_;
#}

#sub update_specific_row {
#    my ($self, $data, $new_fields, $orig_fields) = @_;
#}

# not sure how this one works yet
#sub fetch_one_row { }

# not sure what this one does
#sub display_name { }

# corresponds to a SQL command to drop the table
sub drop {
    my ($self) = (@_);
    if ($self->{fh}) {
        close $self->{fh};
    }
    unlink "$self->{file_base}.tbl";
    unlink "$self->{file_base}.cols";
    return 1;
}

sub fetch_row {
    my ($self, $data) = @_;

    my $fh = $self->{fh};
    my $line = <$fh>;
    return undef if not $line;
    chomp $line;

    my @fields = split /\|/, $line, scalar($self->{col_names});
    # put them back to |s to maintain integrity
    for (@fields) {
        $_ =~ s/&#124;/\|/g;
    }

    $self->{row} = ( @fields ? \@fields : undef );
    return $self->{row};    
}

sub push_row {
    my ($self, $data, $fields) = @_;

    # make sure undefined fields still get put in & write.
    # added bonus of stopped a bunch of undef warnings
    @$fields = map { defined $_ ? $_ : '' } @$fields;

    # we have to nuke all |s, because that's our delimeter...
    for (@$fields) { $_ =~ s/\|/&#124;/g; }

    # handle primary key
    if (defined $self->{primary_key} and $self->{primary_key} ne "") {
        my $col = $self->{col_nums}{uc($self->{primary_key})};
        if ($fields->[$col] eq "") {
            die "Primary Key field ($self->{primary_key}) cannot be empty!";
        #    $fields->[$col] = $self->_get_next_pk();
        }
        else {
        #    $self->_check_pk();
        }
        #else {
        #    $self->_update_next_pk($fields->[$col]);
        #}
    }

    my $fh = $self->{fh};
    print $fh join('|', @$fields);
    print $fh "\n";

    return 1;
}

sub push_names {
    my ($self, $data, $row) = @_;

    my $col_fh;
    my $created = 0;
    if (not -e "$self->{file_base}.cols") {
        $created = 1;
        open $col_fh, '>', "$self->{file_base}.cols"
            or die "Could not create columns $self->{file_base}.cols: $!";
    }
    else {
        open $col_fh, '+<', "$self->{file_base}.cols"
            or die "Could not read/write columns $self->{file_base}.cols: $!";
    }
    if ($YaBB3::DataSource::File::can_lock) {
        flock $col_fh, LOCK_EX
            or die "Can't lock $self->{file_base}.cols: $!";
        # we don't want other processes getting confused with weird table data
        if ($data->{fh}) {
            my $tbl_fh = $data->{fh};
            flock $tbl_fh, LOCK_EX
                or die "Can't lock $self->{file_base}.tbl: $!";
        }
    }

    # if we didn't just create this table, get the PK value
    my $pk_val = 0;
    if (not $created) {
        my @lines = <$col_fh>;
        $pk_val = $lines[3];
        chomp $pk_val if defined $pk_val;
        # rewind & nuke current contents
        seek $col_fh, 0, 0
            or die "Seek error for $self->{file_base}.tbl: $!";
        truncate $col_fh, 0
            or die "Truncate error for $self->{file_base}.tbl: $!";
    }

    # store fields in object
    push @{$self->{col_names}}, @$row;
    $self->{col_nums}{$row} = scalar @{$self->{col_names}} - 1;

    # store data types and PK
    my $cols = $self->{col_names};
    my @types;
    my $pk = undef;
    for my $col (@$row) {
        my $cd = $data->{stmt}{column_defs}{$col};
        push @types, $cd->{data_type};
        if (not defined $pk and $cd->{constraints}) {
            if (scalar grep {$_ eq "PRIMARY KEY"} @{$cd->{constraints}}) {
                $pk = $col;
            }
        }
    }

    $self->{col_datatypes} = \@types;
    if (defined $pk) { $self->{primary_key} = uc($pk); }

    print $col_fh uc(join('|', @{$self->{col_names}})), "\n";
    print $col_fh uc(join('|', @types)), "\n";
    print $col_fh ( defined $pk ? $pk : '' ), "\n";
    #print $col_fh ( defined $pk_val ? $pk_val : 0 );

    close $col_fh;
}

sub seek {
    my ($self, $data, $pos, $whence) = @_;
    if ($whence == 0 and $pos == 0) {
        $pos = $self->{first_row_pos};
    }
    elsif ($whence != 2 or $pos != 0) {
        die "Illegal seek: pos = $pos, whence = $whence";
    }

    seek $self->{fh}, $pos, $whence
        or die "Seek error for $self->{file_base}.tbl: $!";
    return 1;
}

sub truncate {
    my ($self, $data) = @_;
    truncate $self->{fh}, tell($self->{fh})
        or die "Truncate error for $self->{file_base}.tbl: $!";
    return 1;
}

1;
__END__
=pod

=head1 NAME

YaBB3::DataSource::File - Provides a file base data source for YaBB 3

=head1 SYNOPSIS

  This is a driver for YaBB3::DataSource. Do not call it directly.

=head1 DESCRIPTION

This is the file backend driver for YaBB3. It uses L<SQL::Statement> to parse 
the SQL queries. Because we don't want to depend on DBI, I can't use
L<DBD::File> in this module. I did use the DBD::File source as a guide on how
I should properly do things, so that I wouldn't forget important things.

The guys who wrote C<SQL::Statement> and C<DBD::File> are awesome--despite
their code being a bit frightening. Without their documentation and code this
would have been 100 times harder.

=head1 METHODS

=head2 new(option => 'value')

This functions is usually called by the YaBB3::DataSource module. It will
supply the user, password and database arguments based on the current board's
configuration.

=head3 Options

=over

=item database

This is the name of the database to connect to. It should be set by the user
of the module. This will be a subdirectory in the database directory defined
by the Paths modules. (C<YaBB3::Paths::DatabaseDir>)

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

=head1 ACKNOWLEDGMENTS

The team would like to thank the following people for their help. Whether they
know it or not, they have helped YaBB in a big way.

=over

=item * Jeff Zucker for SQL::Statement and contributions to DBD::File.

=item * H.Merijn Brand for contributions to DBD::File

=item * Jehns Rehsack for contributions to DBD::File

=item * Jochen Wiedmann for creating DBD::File

=back


=head1 SEE ALSO

L<YaBB3::DataSourcE>, L<SQL::Statement>, L<DBD::File>

=head1 COPYRIGHT

This module was written by Matt Siegman as part of the YaBB 3 project.

Copyright (C) 2002-2008, YaBB 3 Development Team. All Rights Reserved. You may
distribute this module under the terms of YaBB 3.

=cut
