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
use AccessorSimpleTest::RequiredInitArg; 

new_ok('AccessorSimpleTest::NewInjected');

throws_ok( sub{ AccessorSimpleTest::RequiredInitArg->new }, 'Exception::Simple', 'arg is required');

#this is a compile time error, which is why it's like this
throws_ok( sub{ require AccessorSimpleTest::InvalidDefault }, qr/foo => default is not a coderef/);

#check all things
 # 'is' is proved
 # ro/rw works as expected
 # default works
 # custom init_arg works
 # builder works
 # selective import works
 # check that if two objects of the same class are instanciated, that they can hold differnt data (that the data is in the obect and not the namespace)
 # on demand use of has, i.e. in random sub somewhere
 # strict and warnings are imported into target
 # other?
