package Ocean::Stanza::DeliveryRequest::IQError;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Util::JID qw(to_jid);
use Ocean::Constants::MessageType;

__PACKAGE__->mk_accessors(qw(
    id
    from
    to
    error_type
    error_reason
    error_text
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{from} = to_jid($self->{from});
    $self->{to}   = to_jid($self->{to});
    return $self;
}

1;
