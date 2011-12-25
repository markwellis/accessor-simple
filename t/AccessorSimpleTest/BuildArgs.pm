package AccessorSimpleTest::BuildArgs;
use Accessor::Simple;

has 'harry' => (
    'is' => 'ro',
    'required' => 1,
);

has 'jen' => (
    'is' => 'ro',
    'required' => 1,
);

sub BUILDARGS{
    my ( $self, $args ) = @_;

    #this is a bad example, but it's an example
    return {
        'harry' => $args->[0],
        'jen' => $args->[1],
    };
};

1;
