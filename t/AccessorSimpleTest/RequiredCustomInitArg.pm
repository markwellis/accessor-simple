package AccessorSimpleTest::RequiredCustomInitArg;

use Accessor::Simple;

has 'accessor_for_custom' => (
    'is' => 'ro',
    'init_arg' => 'custom',
    'required' => 1,
);

1;
