package AccessorSimpleTest::Ro;
use Accessor::Simple;

has 'foo' => (
    'is' => 'ro',
    'default' => sub { return "this is unchangable" },
);

1;
