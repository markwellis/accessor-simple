package AccessorSimpleTest::InvalidDefault;
use strict;
use warnings;

use Accessor::Simple;

has 'foo' => (
    'is' => 'ro',
    'default' => \"this isn't a coderef!",
);

1;
