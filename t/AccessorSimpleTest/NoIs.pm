package AccessorSimpleTest::NoIs;
use strict;
use warnings;

use Accessor::Simple;

has 'foo' => (
    'default' => sub { return "lol this isn't right..." },
);

1;
