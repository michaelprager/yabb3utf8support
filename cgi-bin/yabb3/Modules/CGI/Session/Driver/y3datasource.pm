package CGI::Session::Driver::y3datasource;
use strict;
use base qw( CGI::Session::Driver CGI::Session::ErrorHandler );

sub init {
    my ($self) = @_;
    if (not defined $self->{DS}) {
        die "DS parameter must be passed to session.";
    }
}

sub store {
    my ($self, $sid, $datastr) = @_;

    # check to see if it's there
    my $sth = $self->{DS}->do_query("SELECT id FROM {sessions} WHERE id = ?",
                                    [ $sid, ]);
    my $data = $sth->fetch;

    # new session
    if (not defined $data->[0]) {
        $self->{DS}->do_query("INSERT INTO {sessions} (id, a_session) VALUES (?,?)",
                              [ $sid, $datastr, ]);
    }
    # update session
    else {
        $self->{DS}->do_query("UPDATE sessions SET a_session = ? WHERE id = ?",
                              [ $datastr, $sid, ]);
    }

    return 1;
}

sub retrieve {
    my ($self, $sid) = @_;
    my $sth = $self->{DS}->do_query("SELECT a_session FROM {sessions} WHERE id = ?",
                                    [ $sid, ]);
    my $data = $sth->fetch;

    return defined $data->[0] ? $data->[0] : "" ;
}

sub remove {
    my ($self, $sid) = @_;

    $self->{DS}->do_query("DELETE FROM {sessions} WHERE id = ?", [ $sid, ]);

    return 1;
}

sub traverse {
    my ($self, $coderef) = @_;

    my $sth = $self->{DS}->do_query("SELECT id FROM {sessions}");

    while ( defined (my $row = $sth->fetch ) ) {
        $coderef->($row->[0]);
    }

    return 1;
}
