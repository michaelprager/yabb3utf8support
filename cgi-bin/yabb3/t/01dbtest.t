#!/usr/bin/perl -wT --

use Test::More;
use strict;

use lib '.';
use lib './Modules';
use YaBB3::DataSource;

open my $schema, '<', 'db/schema.sql' or die "crappers! $!";
my $data = do { local $/; <$schema> };
close $schema;

my @tests = map { { $_ => undef } } (split /;/, $data)[0];
=oid
my @tests = (
 {"  DROP TABLE IF EXISTS group_id" => undef,},
 {"  CREATE TABLE group_id (username CHAR(26),uid INT, gid INT)" => undef,},
 {"  INSERT INTO group_id VALUES('joe',1,1)" => undef,},
 {"  INSERT INTO group_id VALUES('sue',2,1)" => undef,},
 {"  INSERT INTO group_id VALUES('bob',3,2)" => undef,},
 {"  SELECT * FROM group_id " =>
q{joe 1 1
sue 2 1
bob 3 2
},},
{"   drop table if exists test2" => undef,},
{"   create table test2 (
        pid integer primary key,
        name varchar(100),
        salary decimal(10,2)
    )" => undef,},
 {"  INSERT INTO test2  VALUES (1, 'joe', 45505.23)" => undef,},
 {"  INSERT INTO test2  VALUES (2, 'sue', 55505.23)" => undef,},
 {"  INSERT INTO test2  VALUES (3, 'bob', 65505.23)" => undef,},
{ "  INSERT INTO test2  VALUES (4, 'bob', 75505.23)" => undef,},
 {"  INSERT INTO test2  VALUES (143, 'bob', 75500.23)" =>
undef,},
 {"  INSERT INTO test2  VALUES (144, 'bob', 85505.23)" => undef,},
 {"  INSERT INTO test2  VALUES (145, 'bob', 95505.23)" => undef,},
 {"  INSERT INTO test2  VALUES (146, 'ed', 15505.23)" => undef,},
 {"  select PID, NAME, salary FROM test2" =>
q{1 joe 45505.23
2 sue 55505.23
3 bob 65505.23
4 bob 75505.23
143 bob 75500.23
144 bob 85505.23
145 bob 95505.23
146 ed 15505.23
},},
 {"  update test2 set name = 'john' where pid = 143" => undef,},
 {"  select PID, NAME, salary FROM test2" => 
q{1 joe 45505.23
2 sue 55505.23
3 bob 65505.23
4 bob 75505.23
143 john 75500.23
144 bob 85505.23
145 bob 95505.23
146 ed 15505.23
},},
 {"  delete from test2 where name = 'bob'" => undef,},
 {"  select PID, NAME, salary FROM test2 " =>
q{1 joe 45505.23
2 sue 55505.23
143 john 75500.23
146 ed 15505.23
},},
 {"  CREATE TABLE Personnel
(emp CHAR(10) PRIMARY KEY,
salary DECIMAL(6,2) NOT NULL,
lft INTEGER NOT NULL,
rgt INTEGER NOT NULL)" => undef, },
 {"  drop table if exists Personnel" => undef, },
 {"  drop table if exists nested_category" => undef, },
 {"  CREATE TABLE nested_category (
 category_id INT PRIMARY KEY,
 name VARCHAR(20) NOT NULL,
 lft INT NOT NULL,
 rgt INT NOT NULL
)
" => undef, },
 {"  INSERT INTO nested_category VALUES (1,'ELECTRONICS',1,20)" => undef, },
 {"  INSERT INTO nested_category VALUES (2,'TELEVISIONS',2,9)" => undef, },
 {"  INSERT INTO nested_category VALUES (3,'TUBE',3,4)" => undef, },
 {"  INSERT INTO nested_category VALUES (4,'LCD',5,6)" => undef, },
 {"  INSERT INTO nested_category VALUES (5,'PLASMA',7,8)" => undef, },
 {"  INSERT INTO nested_category VALUES (6,'PORTABLE ELECTRONICS',10,19)" => undef, },
 {"  INSERT INTO nested_category VALUES (7,'MP3 PLAYERS',11,14)" => undef, },
 {"  INSERT INTO nested_category VALUES (8,'FLASH',12,13)" => undef, },
 {"  INSERT INTO nested_category VALUES (9,'CD PLAYERS',15,16)" => undef, },
 {"  INSERT INTO nested_category VALUES (10,'2 WAY RADIOS',17,18)" => undef, },
 {"  SELECT * FROM nested_category ORDER BY category_id" => 
q{1 ELECTRONICS 1 20
2 TELEVISIONS 2 9
3 TUBE 3 4
4 LCD 5 6
5 PLASMA 7 8
6 PORTABLE ELECTRONICS 10 19
7 MP3 PLAYERS 11 14
8 FLASH 12 13
9 CD PLAYERS 15 16
10 2 WAY RADIOS 17 18
}, },
 {"  SELECT name FROM nested_category  WHERE (12 >= lft AND 12 <= rgt)
     ORDER BY lft" => q{ELECTRONICS
PORTABLE ELECTRONICS
MP3 PLAYERS
FLASH
}, } ,
);
=cut

#plan tests => 3 + 3 * scalar @tests;
plan tests => 1 + scalar @tests;

#for my $type (qw/File MySQL SQLite/) {
for my $type (qw/File/) {
    my $ds;
    ok($ds = YaBB3::DataSource->new(
        type => $type,
        user => 'root',
        database => 'YaBB3' ), 'create ds');
    for (@tests) {
        my ($test_str, $answer) = %$_;
        if (not defined $answer) {
            ok( run_sql( $ds, $test_str ), $test_str);
        }
        else {
            is( run_sql( $ds, $test_str ), $answer, $test_str );
        }
    }
}

sub run_sql {
    my ($ds, $sql) = @_;
    my ($stmt, $rv);
    eval {
        $stmt = $ds->prepare($sql);
        $rv = $stmt->execute;
    };
    if ($@) { diag($@); return 0; }
    return $rv unless $sql =~ /select/i;
    my $out = "";
    while (my $row = $stmt->fetch) {
        $out .= "@$row\n";
    }
    return $out;
}
