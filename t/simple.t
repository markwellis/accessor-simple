use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path( $0 ) );

use Test::More;
use Test::Exception;

use AccessorSimpleTest::Rw;
my $foo = new_ok('AccessorSimpleTest::Rw', [{
    'foo' => 1,
}]);

is( $foo->foo, 1, 'foo value correct' );
my $bar = new_ok('AccessorSimpleTest::Rw', [{
    'foo' => 2,
}]);
is( $foo->foo, 1, 'foo value correct' );
is( $bar->foo, 2, 'bar value correct' );

isnt( $foo->foo, $bar->foo, '2 objects of the same class hold different data');

done_testing;
