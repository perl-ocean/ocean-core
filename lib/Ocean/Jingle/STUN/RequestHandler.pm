package Ocean::Jingle::STUN::RequestHandler;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Handler';
use Ocean::Jingle::STUN::ClassType qw(REQUEST);

use Log::Minimal;


sub dispatch_message {
    my ($self, $sender, $msg) = @_;

    if ($msg->class ne REQUEST) {
        infof('<Handler> "%s" method should be "REQUEST" class', 
            $msg->method);
        return;
    }

}

1;
