package AccessorSimpleTest::CustomInitArg;

use Accessor::Simple;

has 'accessor_for_custom' => (
    'is' => 'ro',
    'init_arg' => 'custom',
);

1;
