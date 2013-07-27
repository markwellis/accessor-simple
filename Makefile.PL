use inc::Module::Install;

all_from('lib/Accessor/Simple.pm');

requires 'Clone';
requires 'Exception::Simple';
test_requires 'Moo';
test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'Cwd';
test_requires 'File::Basename';

perl_version '5.008';

resources(
    'repository'  => 'https://github.com/n0body-/accessor-simple.git',
);

auto_install;
WriteAll;
