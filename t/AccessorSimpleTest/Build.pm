package AccessorSimpleTest::Build;
use Accessor::Simple;

has 'country' => (
    'is' => 'ro',
    'required' => 1,
);

has 'ni_number' => (
    'is' => 'ro',
);

sub BUILD{
    my ( $self ) = @_;

    if ( 
        ( $self->country eq 'uk' )
        && ( !$self->ni_number )
    ){
        Exception::Simple->throw('must have ni_number if from the uk')
    }
}

1;
