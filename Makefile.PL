#!/usr/bin/perl -w
use lib 'lib';
use lib 'inc';

use strict;

use Cwd             qw[cwd];
use IPC::Cmd        qw[run can_run];
use File::Fetch;
use File::Basename 	qw[dirname];

use File::Spec;
use ExtUtils::MakeMaker;

require Alien::Zlib;

### if you only want to write the makefile for 'make dist'
### invoke it as 'perl Makefile.PL dist'

my $zlib; my $cwd; my $progs = {};
unless( $ARGV[0] eq 'dist' ) {

    ### find required programs ###
    for my $pgm ( qw[sh make tar gzip] ) {
        $progs->{$pgm} = can_run($pgm) 
                            or die qq[Cannot locate required program '$pgm'\n];
    }
    
    $zlib   = 'zlib-' . Alien::Zlib->version;
    $cwd = cwd();
    
    ### fetch the sources ###
    my $src = fetch_zlib();
    chdir $cwd;
    
    ### extract them ###
    my $dir = extract_zlib($src);
    chdir $cwd;
    
    ### patch && install ###
    install_zlib();
    chdir $cwd;
}

### Write the makefile ###
WriteMakefile(
    NAME            => 'Alien::Zlib',
    VERSION_FROM    => 'lib/Alien/Zlib.pm',
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    AUTHOR          => 'Jos Boumans <kane[at]cpan.org>',
	ABSTRACT        => 'Supply external zlib library'
);             


### SUB ROUTINES ###

sub fetch_zlib {
    my @urls =( "http://www.gzip.org/zlib/${zlib}.tar.gz",
                "http://www.zlib.net/${zlib}.tar.gz" );
    my $dir  = File::Spec->catdir($cwd, 'src');                 
                    
    for my $url (@urls) {
        print "Trying to fetch $url\n";
    
        my $ff  = File::Fetch->new( uri => $url ) or next;
        my $loc = $ff->fetch( to => $dir );
        
        next unless $loc;
        
        print "Successfully fetched zlib\n";
        return $loc;
    }
    
    ### if we got here, we weren't able to fetch the source files ###
    die "Unable to fetch the zlib sources -- cannot continue\n";
}

sub extract_zlib {
    my $loc = shift;
    
    chdir dirname($loc);

    my $cmd = qq[$progs->{gzip} -cd $loc | $progs->{tar} -xf -];

    die "Could not run @$cmd: $!"
        unless scalar run( command => $cmd, verbose => 1 );

    print "successfully extracted zlib\n";
}


sub install_zlib {
    my $dirname  = File::Spec->rel2abs(dirname($0), 'src');
    my $zlib_dir = File::Spec->catdir( $dirname, $zlib ); 
    my $hints 	 = File::Spec->catdir( $dirname, 'hints', $^O );
    my $makefile = File::Spec->catdir( $zlib_dir, 'Makefile' );
    my $prefix   = Alien::Zlib->prefix;
    my $include  = Alien::Zlib->include;
    my $lib      = Alien::Zlib->lib;
    
    ### go to the zlib dir ###
    unless( chdir $zlib_dir ) {
        die qq[Could not chdir to '$zlib_dir' -- cannot compile sources\n];
    }	
    
    
    ### build the zlib sources, make sure to copy them into the lib/ dir ###
    my @cmds = (
        [$progs->{'make'}, 'clean' 		],
        [$progs->{'sh'}, 	'configure', @ARGV],
        
        ### patch prefix ###
        [$^X, '-pi.bak', '-e', 's|(^prefix\s*=\s*).*$|$1'.$prefix.'|',
            $makefile],
        
        ### patch include dir ###
        [$^X, '-pi.bak', '-e', 's|(^includedir\s*=\s*).*$|$1'.$include.'|',
             $makefile],

        ### patch lib dir ###
        [$^X, '-pi.bak', '-e', 's|(^libdir\s*=\s*).*$|$1'.$lib.'|',
            $makefile],
        
        ( -e $hints ? [$^X, $hints, $zlib_dir] : [] ),
        [$progs->{'make'},				],
        [$progs->{'make'},	'test'		],
        [$progs->{'make'},	'install'	],
    );
   
    shift @cmds unless -e 'Makefile';
   
    for my $cmd (@cmds) {
        next unless @$cmd;
        unless( scalar run( command => [@$cmd],
                            verbose => 1, ) 
        ) {
            die qq[Could not run '@$cmd': $!]
        }      	                    
    }
    
    print "Successfully compiled $zlib\n";
}
