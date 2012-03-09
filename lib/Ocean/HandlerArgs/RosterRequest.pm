package Ocean::HandlerArgs::RosterRequest;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    from   
    id
    want_photo_url
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{from} = to_jid($self->{from});
    return $self;
}


1;
