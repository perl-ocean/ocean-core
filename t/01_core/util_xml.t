use strict;
use warnings;

use Test::More tests => 3;

use Ocean::Util::XML qw(
    escape_xml_char 
    unescape_xml_char
    gen_xml_sig
);

is(escape_xml_char(q{foobar<>"'}), q{foobar&lt;&gt;&quot;&#39;});
is(unescape_xml_char(q{foobar&lt;&gt;&quot;&#39;}), q{foobar<>"'});
is(gen_xml_sig(q{http://example.org/ns}, q{foo}), q{http://example.org/ns__foo});

