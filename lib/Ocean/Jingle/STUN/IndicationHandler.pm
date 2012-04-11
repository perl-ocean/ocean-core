package Ocean::Jingle::STUN::IndicationHandler;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Handler';
use Ocean::Jingle::STUN::ClassType qw(INDICATION);

use Log::Minimal;

sub dispatch_message {
    my ($self, $sender, $msg) = @_;

    if ($msg->class ne INDICATION) {
        infof('<Handler> "%s" method should be "INDICATION" class', 
            $msg->method);
        # TODO
        #   if the class is 'REQUEST', should return bad request?
        return;
    }

}

1;
