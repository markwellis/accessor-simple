package AccessorSimpleTest::Rw;
use strict;
use warnings;

use Accessor::Simple;

has 'foo' => (
    'is' => 'rw',
    'default' => sub { return "0" },
);

1;
