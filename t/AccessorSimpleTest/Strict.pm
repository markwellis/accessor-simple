package AccessorSimpleTest::Strict;
use Accessor::Simple;

sub strict_error{
    my $foo = 'bar';
    return $$foo;
}

1;
