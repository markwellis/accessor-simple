package AccessorSimpleTest::CustomNew;
use Accessor::Simple 'no_new';

sub new{
    Exception::Simple->throw("custom new");
}

1;
