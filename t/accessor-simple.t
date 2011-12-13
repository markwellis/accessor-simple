use strict;
use warnings;

#use our Test.pm files
use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path( $0 ) );

use Test::More;
use Test::Exception;

#test classes
use AccessorSimpleTest::NewInjected; 
new_ok('AccessorSimpleTest::NewInjected');

use AccessorSimpleTest::RequiredInitArg; 
throws_ok( sub{ AccessorSimpleTest::RequiredInitArg->new }, 'Exception::Simple', 'arg is required');

#there are a compile time errors, which is why they're like this
throws_ok( sub{ require AccessorSimpleTest::InvalidDefault }, qr/foo => default is not a coderef/);
throws_ok( sub{ require AccessorSimpleTest::NoIs }, qr/'foo => is' not provided/);
throws_ok( sub{ require AccessorSimpleTest::InvalidIs }, qr/'foo => is' is invalid/);

{
    use AccessorSimpleTest::Ro;

    my $ro = new_ok('AccessorSimpleTest::Ro');
    is( $ro->foo, 'this is unchangable', 'default ro accessor value is set');
    throws_ok( sub { $ro->foo( 1 ) }, 'Exception::Simple', 'accessor foo is readonly' );
    is( $ro->foo, 'this is unchangable', "foo hasn't been changed");

    $ro = new_ok('AccessorSimpleTest::Ro', [{
        'foo' => 1,
    }]);
    is( $ro->foo, 1, 'readonly accessor can be set at object instanciation');
}

{
    use AccessorSimpleTest::Rw;

    my $rw = new_ok('AccessorSimpleTest::Rw');
    is( $rw->foo, '0', 'default rw accessor value is set');
    is( $rw->foo( 1 ), '1', 'accessor foo value change' );
    is( $rw->foo, '1', "new value for foo set");

    $rw = new_ok('AccessorSimpleTest::Rw', [{
        'foo' => 1,
    }]);
    is( $rw->foo, 1, 'rw accessor can be set at object instanciation');
    is( $rw->foo( 2 ), '2', 'accessor foo value change' );
    is( $rw->foo, '2', "new value for foo set");
}

{
    use AccessorSimpleTest::CustomInitArg;
    my $custom_init_arg = new_ok('AccessorSimpleTest::CustomInitArg', [{
        'custom' => 'foo',
    }]);
    is( $custom_init_arg->accessor_for_custom, 'foo', 'custom init arg works');
}

#check all things
 # builder works ( custom getter/setter? )
 # sub BUILD (others?) works
 # selective import works
 # check that if two objects of the same class are instanciated, that they can hold differnt data (that the data is in the obect and not the namespace)
 # on demand use of has, i.e. in random sub somewhere
 # strict and warnings are imported into target
 # other?
