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
#use YaBB3::Language qw/ERROR/;
#use YaBB3::Settings;
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

=head1 TITLE

 YaBB3::DataSource

=head1 SYNOPSIS

 YaBB3::DataSource->new(type => "MySQL");

=head1 DESCRIPTION

This modules loads the necessary data interface driver and provides some
utility functions.

=head1 FUNCTIONS

=head2 new

blah

=head1 LICENSE

This module is licensed under the same terms as YaBB.

=head1 AUTHOR

Matthew Siegman
Copyright (c) 2000-2009 YaBB (www.yabbforum.com) - All Rights Reserved.

=cut

