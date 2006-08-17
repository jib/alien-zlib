use inc::Module::Install;

name            ('Alien-Zlib');
abstract        ('Install the zlib-libary');
author          ('Jos Boumans <kane[at]cpan.org>');
license         ('perl');
requires        ('perl' => 5.005);
build_requires  ('IPC::Cmd');
build_requires  ('File::Fetch');

auto_include();

&Meta->write;

__END__
WriteMakefile(
    NAME            => 'Alien::Zlib',
    VERSION_FROM    => 'lib/Alien/Zlib.pm',
    PREREQ_PM       => { 'IPC::Cmd'  => '0.04' },
    AUTHOR          => 'Jos Boumans <kane[at]cpan.org>',
    ABSTRACT        => 'Install the zlib-library',
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
);    
                        
                        

