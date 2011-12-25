package AccessorSimpleTest::DynamicHas;
use Accessor::Simple;

sub make_accessor{
    my ( $self, $name, $value ) = @_;

    has $name => (
        'is' => 'ro',
        'default' => sub { return $value },
    );
}

1;
