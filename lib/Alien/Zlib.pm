package Alien::Zlib;

use strict;
use vars qw[$VERSION];

use File::Spec;

$VERSION = '0.00_01';

### sanity check
### only do this one 'use' time, because we use Alien::Zlib from
### the Makefile.PL as well...
sub import {
    require Carp;
    for my $file ( __PACKAGE__->include_files, __PACKAGE__->lib_files ) {
        Carp::croak "Missing file: '$file'\n" unless -e $file;
    }
}

=head1 NAME

Alien::Zlib

=head1 SYNOPSIS

    require Alien::Zlib;

    my $prefix  = Alien::Zlib->prefix;
    my $include = Alien::Zlib->include;
    my $lib     = Alien::Zlib->lib;

    my $ver     = Alien::Zlib->version;

=head1 DESCRIPTION

This module resolves the non-perl prerequisite C<zlib>.
This allows your program/module to depend on the C<zlib> library and
expect common installers, such as C<CPANPLUS> and C<CPAN.pm> to
install them for you.

It does so by installing a private copy of the zlib libraries into
its module directory.

Go to L<http://www.zlib.org> for more information about C<zlib>.

=head1 METHODS

=head2 prefix();

Returns the prefix (ie, the directory) where the C<include> and C<lib>
directores will live.
On a standard unix system, this might be C</usr/local/>

For this module, it will be C<$INC{'Alien/Zlib'}>.

=cut

my $prefix;
sub prefix {
    return $prefix if $prefix;

    my $ext = '.pm';
    $prefix = join '/', split '::', __PACKAGE__;
    $prefix = File::Spec->rel2abs( $INC{$prefix.$ext} );
    $prefix =~ s/$ext$//;

    return $prefix;
}

=head2 lib();

Returns the full path to the C<lib> directory for the C<zlib>
libraries.
On standard unix systems, this might be C</usr/local/lib>

For this module, it will be C<$INC{'Alien/Zlib'}/lib>

=head2 include()

Returns the full path to the C<include> directory for the C<zlib>
libraries.
On standard unix systems, this might be C</usr/local/include>

For this module, it will be C<$INC{'Alien/Zlib'}/include>

=cut

for my $sub (qw[lib include]) {
    no strict 'refs';
    *$sub = sub {
                my $self = shift;
                return File::Spec->catdir( $self->prefix, $sub );
            };
}

=head2 version()

Returns the version of the zlib libraries installed by this version
of C<Alien::Zlib>

=cut

sub version { return '1.2.1'; }

=head2 lib_files()

Returns a list of full paths to the files that can be found in the
'Alien::Zlib->lib' directory. This corresponds to all created
libraries.

=head2 include_files()

Returns a list of full paths to the files that can be found in the
'Alien::Zlib->include' direcotry. This corresponds to all copied
header files.

=cut

my $files = {
    include => [qw|zconf.h zlib.h|],
    lib     => [qw|libz.a|],
};

for my $acc (qw[include_files lib_files]) {
    no strict 'refs';
    *$acc = sub {
                my $self    = shift;
                my ($type)  = $acc =~ /(\w+)_files/;

                return map {
                            File::Spec->catfile( $self->$type(), $_)
                        } @{$files->{$type}};
    }
}

=head1 TODO

=over 4

=item *

Probe for system installed version of C<zlib>

=item *

Gather more C<hints> file to ensure this module builds properly on
all platforms that C<zlib> builds on.

=head1 BUG REPORTS

Please report bugs or other issues to E<lt>bug-alien-zlib@rt.cpan.org<gt>.

=head1 AUTHOR

This module by Jos Boumans E<lt>kane@cpan.orgE<gt>.

=head1 COPYRIGHT

This library is free software; you may redistribute and/or modify it 
under the same terms as Perl itself.

=cut

1;
