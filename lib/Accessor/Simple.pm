package Accessor::Simple;
use strict;
use warnings;

use Data::Dumper;
use Exception::Simple;

our %accessor_control;

sub import{
    my $target = caller;
    my $class = shift;
    my $imports = {};

#can we import strict and warnings into $target?

    if ( scalar( @_ ) ){
        foreach my $import ( @_ ){
            $imports->{ $import } = 1;
#shorten this, so it does import_$import($target) and does both in else, check for proper values
        }
    } else {
        $imports->{'new'} = 1;
        $imports->{'has'} = 1;
    }

    $accessor_control{ $target } = {};

    if ( $imports->{'has'} ){
        import_has( $target );
    }
    if ( $imports->{'new'} ){
        import_new( $target );
    }
}

sub import_new{
    my $target = shift;

    {
        no strict 'refs';
        *{"${target}::new"} = sub{
            my ( $invocant, $args ) = @_;
            my $class = ref( $invocant ) || $invocant;

            my $self = {};
            bless( $self, $class );

#do things with args 
     # set accessor values (including init_arg)
     # check required
     # other?
            foreach my $key ( keys( %{$accessor_control{ $target }} ) ){
                my $accessor = $accessor_control{ $target }->{ $key };
    
                if ( 
                    $accessor->{'required'}
                    && !defined( $args->{ $accessor->{'init_arg'} } ) 
                ){
                    Exception::Simple->throw("$accessor->{'name'} is required");
                }

                my $value = $args->{ $accessor->{'init_arg'} };
            }
            
            return $self;
        };
    }
}

sub import_has{
    my $target = shift;

    {
        no strict 'refs';
        *{"${target}::has"} = sub{
            my ( $name, %args ) = @_;
            
            if ( !exists( $args{'init_arg'} ) ){
                $args{'init_arg'} = $name;
            }

            if (
                exists( $args{'default'} ) 
                && ref( $args{'default'} ) ne 'CODE'
            ){
                Exception::Simple->throw("${name} => default is not a coderef");
            }
            $args{'name'} = $name;
            $accessor_control{ $target }->{ $name } = \%args;
        };
    }
}

1;
