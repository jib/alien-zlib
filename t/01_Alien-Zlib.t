BEGIN { chdir 't' if -d 't' };
use lib '../lib';
use Test::More 'no_plan';
use strict;
use File::Spec;

my $class = 'Alien::Zlib';

use_ok($class);

for my $dir (qw[prefix lib include]) {
    ok( -d $class->$dir(),  "Dir '$dir' exists" );
}    

for my $header ($class->include_files) {
    ok( -e $header, "Header file '$header' found" );
}        

for my $lib ($class->lib_files) {
    ok( -e $lib, "Lib file '$lib' found" );
}

is( $class->version, '1.2.1', "Version OK" );
