package Accessor::Simple;
use strict;
use warnings;

use Exception::Simple;

#add unimport
sub import{
    my $target = caller;
    my ( $class, $no_new ) = @_;

#can we import strict and warnings into $target?
    _import_has( $target );
    _import_new( $target ) if ( $no_new ne 'no_new' );

    strict->import;
    warnings->import;
}

sub _import_new{
    my $target = shift;

    {
        no strict 'refs';
        *{"${target}::new"} = sub{
            my ( $invocant, $args ) = @_;
            my $class = ref( $invocant ) || $invocant;

            my $self = {};
            bless( $self, $class );

            foreach my $key ( keys( %{_get_control( $target )} ) ){
                my $accessor = _get_control( $target )->{ $key };
    
                if ( 
                    $accessor->{'required'}
                    && !defined( $args->{ $accessor->{'init_arg'} } ) 
                ){
                    Exception::Simple->throw("@{[ ( $accessor->{'init_arg'} || $accessor->{'name'} ) ]} is required");
                }

                my $value;
                if ( 
                    exists( $accessor->{'init_arg'} ) 
                    && exists( $args->{ $accessor->{'init_arg'} } ) 
                ){
                    $value = $args->{ $accessor->{'init_arg'} };
                } elsif( exists( $accessor->{'default'} ) ) {
                    $value = $accessor->{'default'}->();
                }

                #set value, ensuring custom setter is used
                my $name = $accessor->{'name'};
                
                _get_control( $target )->{ $name }->{'_init'} = 1;
                $self->$name( $value );
                delete _get_control( $target )->{ $name }->{'_init'};
            }
            
            return $self;
        };
    }
}

sub _get_control{
    my $target = shift;
    {
        no strict 'refs';

        ${"${target}\::"}{'_accessor_control'} ||= {};
        my $control = ${"${target}\::"}{'_accessor_control'};
        
        return $control;
    }
}

#im not sure this needs to be exported, is it not just available? investigate, look at Test::More or something that does similar
sub _import_has{
    my $target = shift;

    {
        no strict 'refs';
        *{"${target}::has"} = sub{
            my ( $name, %args ) = @_;
            
            if ( !exists( $args{'init_arg'} ) ){
                $args{'init_arg'} = $name;
            }

            if ( !$args{'is'} ){
                Exception::Simple->throw("'${name} => is' not provided");
            }

            if (
                $args{'is'} ne 'ro'
                && $args{'is'} ne 'rw'
            ){
                Exception::Simple->throw("'${name} => is' invalid");
            }

            if (
                exists( $args{'default'} ) 
                && ref( $args{'default'} ) ne 'CODE'
            ){
                Exception::Simple->throw("'${name} => default' is not a coderef");
            }

            $args{'name'} = $name;
            _get_control( $target )->{ $name } = \%args;

            _mk_accessor( $target, \%args );
        };
    }
}

sub _mk_accessor{
    my ( $target, $args ) = @_;

    my $name = $args->{'name'};
#these should be overridable in $args...
    my $setter = sub { $_[0]->{ $name } = $_[1] };
    my $getter = sub { return shift->{ $name } };

    my $accessor = sub {
        my ( $self, $value ) = @_;
        if ( 
            $value 
            && ( $args->{'is'} eq 'ro' )
            && !_get_control( $target )->{ $name }->{'_init'}
        ){
            Exception::Simple->throw("accessor ${name} is readonly");
        }
    
        if ( defined( $value ) ){
            $setter->( $self, $value );
        }

        return $getter->( $self );
    };

    {
        no strict 'refs';
        *{"${target}::${name}"} = $accessor;
    }
}

1;
