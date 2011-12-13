package AccessorSimpleTest::Ro;
use strict;
use warnings;

use Accessor::Simple;

has 'foo' => (
    'is' => 'ro',
    'default' => sub { return "this is unchangable" },
);

1;
