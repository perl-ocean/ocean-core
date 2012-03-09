package Ocean::Stanza::DeliveryRequest::vCard;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    to
    request_id
    jid
    nickname
    photo_content_type
    photo
    photo_url
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{to}  = to_jid($self->{to});
    $self->{jid} = to_jid($self->{jid});
    return $self;
}

1;
