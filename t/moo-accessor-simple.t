use strict;
use warnings;

#use our Test.pm files
use Cwd 'abs_path';
use File::Basename;
use lib dirname( abs_path( $0 ) );
use lib dirname( abs_path( $0 ) ) . '/MooTest';

use Test::More;
use Test::Exception;

#test classes
{
    use AccessorSimpleTest::NewInjected; 
    new_ok('AccessorSimpleTest::NewInjected');
}

{
    use AccessorSimpleTest::RequiredInitArg; 
    throws_ok( sub{ AccessorSimpleTest::RequiredInitArg->new }, qr/Missing required arguments/, 'arg is required');
}

{
    #there are a compile time errors, which is why they're like this
    throws_ok( sub{ require AccessorSimpleTest::InvalidDefault }, qr/Invalid default/);
    throws_ok( sub{ require AccessorSimpleTest::NoIs }, qr/Must have an is/);
    throws_ok( sub{ require AccessorSimpleTest::InvalidIs }, qr/Unknown is invalid/);
}

{
    use AccessorSimpleTest::Ro;

    my $ro = new_ok('AccessorSimpleTest::Ro');
    is( $ro->foo, 'this is unchangable', 'default ro accessor value is set');
    throws_ok( sub { $ro->foo( 1 ) }, qr/foo is a read-only accessor/, 'accessor foo is readonly' );
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
    use AccessorSimpleTest::Rw;

    my $foo = new_ok('AccessorSimpleTest::Rw', [{
        'foo' => 1,
    }]);
    my $bar = new_ok('AccessorSimpleTest::Rw', [{
        'foo' => 2,
    }]);
    isnt( $foo->foo, $bar->foo, '2 objects of the same class hold different data');
}

{
    use AccessorSimpleTest::CustomInitArg;
    my $custom_init_arg = new_ok('AccessorSimpleTest::CustomInitArg', [{
        'custom' => 'foo',
    }]);
    is( $custom_init_arg->accessor_for_custom, 'foo', 'custom init arg works');
}

{
    no strict;
    use AccessorSimpleTest::Strict;
    my $foo = AccessorSimpleTest::Strict;
    throws_ok( sub { $foo->strict_error }, qr/Can't use string \("bar"\) as a SCALAR ref while "strict refs"/, 'strict is imported' );
}

{
    use AccessorSimpleTest::RequiredCustomInitArg;
    throws_ok( sub{ AccessorSimpleTest::RequiredCustomInitArg->new }, qr/Missing required arguments: custom/, 'arg is required');
}

{
    use AccessorSimpleTest::NoNew;
    throws_ok( sub{ AccessorSimpleTest::NoNew->new }, qr/Can't locate object method "new" via package "AccessorSimpleTest::NoNew"/, 'no new' );
}

{
    use AccessorSimpleTest::BuildArgs;
    my $foo = new_ok('AccessorSimpleTest::BuildArgs', [ [1, 2] ] );

    is( $foo->harry, 1, 'harry is set' );
    is( $foo->jen, 2, 'jen is set' );
}

{
    use AccessorSimpleTest::Build;

    new_ok('AccessorSimpleTest::Build', [ {
        'country' => 'usa',
    } ] );

    throws_ok( sub{ AccessorSimpleTest::Build->new( { 'country' => 'uk' } ) }, qr/must have ni_number if from the uk/, 'dies because of no ni_number' );

    new_ok('AccessorSimpleTest::Build', [ {
        'country' => 'uk',
        'ni_number' => 12345678,
    } ] );
}

{
    use AccessorSimpleTest::DynamicHas;
    my $test = new_ok('AccessorSimpleTest::DynamicHas');
    $test->make_accessor('test', 'value');

    is( $test->test, 'value', 'dynamic use of has' );
}

{
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
}

done_testing;

#TODO tests
 # on demand use of has, i.e. in random sub somewhere ( + on 2 objects of the same class, see if the methods transfer across objects)

#TODO module side
 # accessor validator? (fix buildargs test to use validator)
 # safe accessor name checks 
 # trigger
 # clearer...
 # unimport
 # has_ accessor?
 # clear_ accessor

#TODO other
 # benchmark Moose, Moo, Class::Accessor, Accessor::Simple (fingers crossed)
