package Ocean::ProjectTemplate::Messages;

use strict;
use warnings;

use Ocean::Error;

sub new { bless {}, $_[0] }

sub get_message_of {
    my ($self, $type) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::Messages::get_message_of}, 
    );
}

1;
