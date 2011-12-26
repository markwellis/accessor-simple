use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path( $0 ) );

use Test::More;
use Test::Exception;

use AccessorSimpleTest::Rw;
use Data::Dumper;
my $foo = new_ok('AccessorSimpleTest::Rw', [{
    'foo' => 1,
}]);

my $bar = new_ok('AccessorSimpleTest::Rw', [{
    'foo' => 2,
}]);

isnt( $foo->foo, $bar->foo, '2 objects of the same class hold different data');
