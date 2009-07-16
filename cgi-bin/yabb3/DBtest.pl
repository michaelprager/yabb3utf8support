#!/usr/bin/perl --

use lib '.';
use lib './Modules';
use YaBB3::DataSource;

my $ds = YaBB3::DataSource->new( type => 'File', database => 'test' );
 for my $sql(split /\n/,
 #"  DROP TABLE IF EXISTS group_id
 #   CREATE TABLE group_id (username CHAR,uid INT, gid INT)
 #   INSERT INTO group_id VALUES('joe',1,1)
 #   INSERT INTO group_id VALUES('sue',2,1)
 #   INSERT INTO group_id VALUES('bob',3,2)
 #   SELECT * FROM group_id
 "  CREATE TABLE test2 ( pid INTEGER PRIMARY KEY, name TEXT, salary FLOAT )
    INSERT INTO test2 (name, salary) VALUES ('joe', 45505.23)
    INSERT INTO test2 (name, salary) VALUES ('sue', 55505.23)
    INSERT INTO test2 (name, salary) VALUES ('bob', 65505.23)
    INSERT INTO test2 (name, salary) VALUES ('bob', 75505.23)
"
 ){
    my $stmt = $ds->prepare($sql);
    $stmt->execute;
    next unless $sql =~ /select/i;
    #next unless $stmt->command eq 'SELECT';
    while (my $row=$stmt->fetch) {
        print "@$row\n";
    }
 }
