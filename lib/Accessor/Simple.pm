package Accessor::Simple;
use strict;
use warnings;

our $VERSION = '0.001';
$VERSION = eval $VERSION;

use Exception::Simple;
use Clone qw/clone/;

#add unimport
sub import{
    my $target = caller;
#error if has and new exist, and arn't our own (subclasses)

    _import_has( $target );
    _import_new( $target );

    strict->import;
    warnings->import;
}

sub _get_control{
    my $target = shift;

    if ( ref( $target ) ){
        return $target->{'_accessor_control'};
    } else {
        no strict 'refs';

        ${"${target}::"}->{'_accessor_control'} ||= {};
        return ${"${target}::"}->{'_accessor_control'};
    }
}

sub _import_new{
    my $target = shift;

    my $new = sub{
        my ( $invocant, $args ) = @_;
        my $class = ref( $invocant ) || $invocant;

        my $self = {
            '_accessor_control' => clone( _get_control( $class ) ),
        };
        bless( $self, $class );
        
        if ( $self->can('BUILDARGS') ){
            $args = $self->BUILDARGS( $args );
            if ( ref( $args ) ne 'HASH' ){
                Exception::Simple->throw("BUILDARGS didn't return a hashref");
            }
        }

        my $control = _get_control( $self );
        foreach my $name ( keys( %{$control} ) ){
            my $accessor = $control->{ $name };

            if ( 
                $accessor->{'required'}
                && !exists( $args->{ $accessor->{'init_arg'} } ) 
            ){
                Exception::Simple->throw("@{[ ( $accessor->{'init_arg'} || $name ) ]} is required");
            }
            if ( exists( $args->{ $accessor->{'init_arg'} } ) ){
                $accessor->{'init_value'} = $args->{ $accessor->{'init_arg'} }; 
            }
        }

        if ( $self->can('BUILD') ){
            $self->BUILD;
        }

        return $self;
    };

    {
        no strict 'refs';
        *{"${target}::new"} = $new;
    }
}

sub _import_has{
    my $target = shift;

    my $has = sub{
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
        #used by new
        _get_control( $target )->{ $name } = \%args;
        
        _mk_accessor( $target, \%args );
    };

    {
        no strict 'refs';
        *{"${target}::has"} = $has;
    }
}

sub _mk_accessor{
    my ( $target, $args ) = @_;

    my $name = $args->{'name'};
    my $accessor = sub {
        my ( $self, $value ) = @_;
        
        my $control = _get_control( $self )->{ $name };
        if ( 
            $value 
            && ( $args->{'is'} eq 'ro' )
        ){
            Exception::Simple->throw("accessor ${name} is readonly");
        }

        if ( defined( $value ) ){
            $control->{'value'} = $value;
            $control->{'is_set'} = 1 if !$control->{'is_set'};
        } elsif ( !$control->{'is_set'} ){
            if ( exists( $control->{'init_value'} ) ){
                $control->{'value'} = $control->{'init_value'};
            } elsif ( exists( $args->{'default'} ) ){
                $control->{'value'} = $args->{'default'}->();
            } else {
                $control->{'value'} = undef;
            }
            $control->{'is_set'} = 1;
        }

        return $control->{'value'};
    };

    {
        no strict 'refs';
        *{"${target}::${name}"} = $accessor;
    }
}

1;
