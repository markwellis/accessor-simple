package AccessorSimpleTest::Rw;
use Accessor::Simple;

has 'foo' => (
    'is' => 'rw',
    'default' => sub { return "0" },
);

1;
