package AccessorSimpleTest::NoIs;
use Accessor::Simple;

has 'foo' => (
    'default' => sub { return "lol this isn't right..." },
);

1;
