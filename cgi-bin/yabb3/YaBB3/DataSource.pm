package YaBB3::DataSource;
use strict;
###############################################################################
# YaBB3/DataSource.pm                                                         #
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

use File::Find ();
use File::Basename ();
use YaBB3::Language qw/ERROR/;
use YaBB3::Settings;

#TODO: REMOVE when code ready to be used in main source
$SETTINGS::ModuleDir = "YaBB3";

my $DS_LOADED = 0;

# this code finds the installed data source modules
my @modules;
File::Find::find( {wanted => \&perl_modules} ,
                  "$SETTINGS::ModuleDir/DataSource" );
my %module_for = 
    map { (File::Basename::fileparse($_, qr/\.[^.]*/))[0] => $_ }
    @modules;
sub perl_modules { /^.*\.pm\z/s && push(@modules, $File::Find::name); }


sub new {
    my $class = shift;
    die "Hash required when calling YaBB3::DataSource->new()" if @_ % 2 == 1;
     #"$LANG::ERROR{HASH_REQUIRED} YaBB3::DataSource->new()" if @_ % 2 == 1;
    my %args = @_;

    # argument validation
    if ($DS_LOADED) {
        die "Data source already loaded."# $LANG::ERROR{DS_ALREADY_LOADED};
    }
    if (not defined $args{type} or $args{type} eq "") {
        $args{type} = "File";
    }
    if (not exists $module_for{$args{type}}) {
        die "Invalid data source." #$LANG::ERROR{INVALID_DS};
    }

    require $module_for{$args{type}};
    return "YaBB3::DataSource::$args{type}"->new();
}

1;

__END__

=pod

=head1 NAME

 YaBB3::DataSource

=head1 SYNOPSIS

    # create object
    my $ds = YaBB3::DataSource->new(type => "some_type");

    # SELECT
    my $sth = $ds->do_query("SELECT * FROM somewhere");
    while (defined(my $row = $sth->fetch)) {
        print "@$row\n";
    }

    # INSERT
    my $sth = $ds->prepare("INSERT INTO somewhere ( ?, ?, ?)");
    $ds->execute($val1, $val2, $val3);


=head1 DESCRIPTION

YaBB3::DataSource is like our own special version of DBI. It loads the drivers
for request DataSources and then gets out of the way. The standard driver API
is defined in this document, and all drivers for YaBB3 must implement the
functions listed in the L<API DEFINITION> section of this document.

YaBB3 code will call these functions to perform data operations. Where SQL
statements are specified as the argument, they will adhere to a standard
subset of SQL, which can be found in the L<VALID SQL> section of this
document.

=head1 FUNCTIONS

=head2 new( type => "SourceType" );

Creates a DataSource object which supports the data source type requested.
Currently, the only argument is type. It defaults to "File" if left blank. The
DataSource types that are planned to ship with YaBB are:

=over

=item MySQL -- Recommended wherever possible.

=item File -- For hosts who do not provide database connectivity.

=back

=head1 VALID SQL

This section describes the SQL queries that must be supported by all
DataSource drivers. Several portions of it were borrowed from the
L<SQL::Statement::Syntax> document so that I wouldn't have to retype it all.

The basic overview of support is:

   CREATE [TEMP] TABLE <table> <column_def_clause>
   DELETE FROM <table> [<where_clause>]
   DROP TABLE [IF EXISTS] <table>
   INSERT [INTO] <table> [<column_list>] VALUES <value_list>
   SELECT <select_clause>
          <from_clause>
          [<where_clause>] 
          [ ORDER BY ocol1 [ASC|DESC], ... ocolN [ASC|DESC]] ]
          [ GROUP BY gcol1 [, ... gcolN] ]
          [ LIMIT [start,] length ]
   UPDATE <table> SET <set_clause> [<where_clause>]

Comments should not be used in SQL, just comment in the Perl code.

Further detail on supported SQL can be found below.

=head2 Joins

The following JOIN types should be supported

=over

=item * NATURAL

=item * INNER

=item * OUTER

=item * LEFT

=item * RIGHT

=item * FULL

=back

=head2 SQL Functions

The following SQL functions should be supported

   * Aggregate : MIN, MAX, AVG, SUM, COUNT
   * Date/Time : CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP
   * String    : CHAR_LENGTH, CONCAT, COALESCE, DECODE, LOWER, POSITION,
                 REGEX, REPLACE, SOUNDEX, SUBSTRING, TRIM, UPPER

=head2 Supported Operators

       $op  = |  <> |  < | > | <= | >=
              | IS NULL | IS NOT NULL | LIKE | CLIKE | BETWEEN | IN

        CLIKE is a case-insensitive LIKE. LIKE should support standard
        wildcards, such as %

=head2 Concatenation

    Use either ANSI SQL || or the CONCAT() function to concatenate data.

=head2 Identifiers and Aliases

   * regular identifiers are case insensitive (though see note on table names)
   * delimited identifiers (inside double quotes) are case sensitive
   * column and table aliases are supported

=head2 CREATE

 CREATE TABLE $table
        (
           $col_1 $col_type1 $col_constraints1,
           ...,
           $col_N $col_typeN $col_constraintsN,
        )
        [ ON COMMIT {DELETE|PRESERVE} ROWS ]

C<col_constriaints> may be "PRIMARY KEY" or one or both of "UNIQUE" and/or "NOT NULL"

C<col_type> is checked for syntax, but is not neccessarily enforced.
C<col_type> must be one of the following types:

=over

=item CHAR( n )

The CHAR structure is a fixed length string of length C<n>. These are
generally limited to a maximum of 255 characters.

=item VARCHAR( n )

The VARCHAR structure is a variable length string, with a set maximum of C<n>.
These are generally limited to a mazimum of 255 characters.

=item TEXT

While not specifically an ANSI type, we must support storage of blocks larger
than 255 characters. TEXT values can store character strings of any length.

=item BLOB

In addition to large text values, we may occasionally need to store large
binary values. BLOB values can store byte strings of any length.

=item INTEGER

INTEGER values may be any positive or negative whole number.

=item DECIMAL( p, s )

DECIMAL is a fixed point number.

The total number of digits of the number is limited to C<p>, the precision.
The number will have a set number of digits to the right of the decimal point
C<s>, the scale. For example: DECIMAL( 5, 3 ) would allow five total digits,
with three to the right of the decimal. 50.3333 would be stored as 50.333
and 33.3456 would be stored as 33.346.

=item FLOAT( p )

A floating point value. A precision from 1 to 21 will result in a single
precision float. A precision from 22-53 will result in a double precision
float. Do not attempt to specify a precision beyond 53.

=item FLOAT

If precision is undefined, the float will be treated as double precision.

=item NUMERIC(p, s)

A number with precision C<p> and scale C<s>.

=item NUMERIC( p )

A NUMERIC with precision C<p> with scale set to 0.

=item NUMERIC

The NUMERIC will only be limited by the specific implementation

=back

=head2 DROP

 DROP TABLE $table 

=head2 INSERT

 INSERT INTO $table [ ( $col1, ..., $colN ) ] VALUES ( $val1, ... $valN )

     * default values are not supported
     * inserting from a subquery is not supported

=head2 DELETE

 DELETE FROM $table [ WHERE search_condition ]

     * see "search_condition" below

=head2 UPDATE

 UPDATE $table SET $col1 = $val1, ... $colN = $valN [ WHERE search_condition ]

     * default values are not supported
     * see "search_condition" below

=head2 SELECT

      SELECT select_clause
        FROM from_clause
     [ WHERE search_condition ]
  [ ORDER BY $ocol1 [ASC|DESC], ... $ocolN [ASC|DESC] ]
     [ LIMIT [start,] length ]

      * select clause ::=
             [DISTINCT|ALL] *
           | [DISTINCT|ALL] col1 [,col2, ... colN]
           | set_function1 [,set_function2, ... set_functionN]

      * set function ::=
             COUNT ( [DISTINCT|ALL] * )
           | COUNT | MIN | MAX | AVG | SUM ( [DISTINCT|ALL] col_name )

      * from clause ::=
             table1 [, table2, ... tableN]
           | table1 NATURAL [join_type] JOIN table2
           | table1 [join_type] table2 USING (col1,col2, ... colN)
           | table1 [join_type] JOIN table2 ON table1.colA = table2.colB

      * join type ::=
             INNER
           | [OUTER] LEFT | RIGHT | FULL

      * search condition ::=
             [NOT] $val1 $op1 $val1 [ ... AND|OR $valN $opN $valN ]

      * $op ::=
                = |  <> |  < | > | <= | >=
              | IS NULL | IS NOT NULL | LIKE | CLIKE | BETWEEN | IN


      * if join_type is not specified, INNER is the default
      * if DISTINCT or ALL is not specified, ALL is the default
      * if start position is omitted from LIMIT clause, position 0 is
        the default
      * ON clauses may only contain equal comparisons and AND combiners
      * self-joins are not currently supported
      * if implicit joins are used, the WHERE clause must contain
        and equijoin condition for each table

=head1 API DEFINITION

This section describes the functions that must be implemented in each
YaBB3::DataSource::* module.

All functions are to C<die> on an error.

See the L< SYNOPSIS > for how this may be used.

=head2 Main DataSource Package

=head3 do_query( $statement, [$val1, $val2, ...] )

Executes a query immediatly. Is equivalent to calling:

  my $sth = $ds->prepare( $statement );
  $sth->execute( $val1, $val2, ... );

=head4 Arguments

=over

=item $statement

Contains a query written in SQL.

=item [$val1, $val2, ...]

Contains the data values to be inserted where placeholders are found.

=back

=head4 Return Value

Returns an object which C<< ->fetch() >> can be called on to return the results
of the statement executed.

=head3 prepare( $statement )

Preparse an SQL query to be executed. Useful for situations when the same
query must executed multiple times with different values

=head4 Arguments

=over

=item $statement

Contains a query written in SQL.

=back

=head4 Return Value

Returns an object which C<< ->execute()> >> and C<< ->fetch() >> can be called 
to execute and retrieve query results.

=head2 Statement Handler Package

=head3 execute( $val1, $val2, ... )

Runs a query using C<$val>, C<$val2>, C<...> for the placeholder values.

=head4 Arguments

=over

=item $val1, $val2, ...

Contains the values to replace the placeholders.

=back

=head4 Return Value

Does not return a value.

=head3 fetch( )

Returns the results of the query that has been run.

=head4 Arguments

None.

=head4 Return Value

Returns an array reference of a single row of data. To get all rows, call
C<< ->fetch() >> until it returns an undefined value.

=head1 REFERENCES

This following links were helpful when creating this document and may contain
further helpful information:

L<SQL::Statement::Syntax>
L<< <a href="http://dev.mysql.com/doc/">MySQL Documentation</a> >>
L<< <a href="http://www.cyberarmy.net/library/article/190">SQL Data Structures</a> >>
L<< <a href="http://home.fnal.gov/~dbox/SQL_API_Portability.html">SQL API Portability</a> >>

=head1 LICENSE

This module is licensed under the same terms as YaBB.

=head1 AUTHOR

Matthew Siegman

Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.

=cut

