package AccessorSimpleTest::RequiredInitArg;

use Accessor::Simple;

has 'arg' => (
    'is' => 'ro',
    'required' => 1,
);

1;
