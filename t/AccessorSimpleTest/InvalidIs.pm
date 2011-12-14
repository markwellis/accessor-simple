package AccessorSimpleTest::InvalidIs;
use Accessor::Simple;

has 'foo' => (
    'is' => 'invalid',
    'default' => sub { return "lol this isn't right..." },
);

1;
