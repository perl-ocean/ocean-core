package Ocean::HTML::Sanitizer;

use strict;
use warnings;

use HTML::Scrubber;

my $SANITIZER;

BEGIN { 
    # XXX make more configurable
    $SANITIZER = 
        HTML::Scrubber->new(allow => [qw(b p hr br)]);
    $SANITIZER->rules(
        img => {
            src    => 1, 
            alt    => 1,
            width  => 1,
            height => 1,
            '*'    => 0,
        }, 
    );
    $SANITIZER->default(0 => {
        '*'           => 1, # default rule, allow all attributes
        'href'        => qr{^(?!(?:java)?script)}i,
        'src'         => qr{^(?!(?:java)?script)}i,
        'cite'        => '(?i-xsm:^(?!(?:java)?script))',
        'language'    => 0,
        'name'        => 1, # could be sneaky, but hey ;)
        'onblur'      => 0,
        'onchange'    => 0,
        'onclick'     => 0,
        'ondblclick'  => 0,
        'onerror'     => 0,
        'onfocus'     => 0,
        'onkeydown'   => 0,
        'onkeypress'  => 0,
        'onkeyup'     => 0,
        'onload'      => 0,
        'onmousedown' => 0,
        'onmousemove' => 0,
        'onmouseout'  => 0,
        'onmouseover' => 0,
        'onmouseup'   => 0,
        'onreset'     => 0,
        'onselect'    => 0,
        'onsubmit'    => 0,
        'onunload'    => 0,
        'src'         => 0,
        'type'        => 0,
    });
};

sub sanitize {
    my ($class, $html) = @_;
    return $SANITIZER->scrub($html);
}

1;
