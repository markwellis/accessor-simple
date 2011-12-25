package Accessor::Simple;
use strict;
use warnings;

use Exception::Simple;
use Data::Dumper;

#add unimport
sub import{
    my $target = caller;
    my ( $class, $no_new ) = @_;

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

    {
        no strict 'refs';
        *{"${target}::new"} = \&_client_new;
    }
}

sub _client_new{
    my ( $invocant, $args ) = @_;
    my $class = ref( $invocant ) || $invocant;

    my $self = {
        '_accessor_control' => _get_control( $invocant ),
    };

    bless( $self, $class );

    if ( $self->can('BUILDARGS') ){
        my $newargs = $self->BUILDARGS( $args );
        if ( ref( $newargs ) ne 'HASH' ){
            Exception::Simple->throw("BUILDARGS didn't return a hashref");
        }
        $args = $newargs;
    }

    foreach my $key ( keys( %{_get_control( $self )} ) ){
        my $accessor = _get_control( $self )->{ $key };

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
        
        $self->$name( $value );
    }

    if ( $self->can('BUILD') ){
        $self->BUILD;
    }

    return $self;
}

#im not sure this needs to be exported, is it not just available? investigate, look at Test::More or something that does similar
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

#check if unset
# if unset set value
        if ( 
            $value 
            && ( $args->{'is'} eq 'ro' )
        ){
            Exception::Simple->throw("accessor ${name} is readonly");
        }
    
        if ( defined( $value ) ){
            _get_control( $self )->{ $name }->{'value'} = $value;
        }

        return _get_control( $self )->{ $name }->{'value'};
    };

    {
        no strict 'refs';
        *{"${target}::${name}"} = $accessor;
    }
}

1;
