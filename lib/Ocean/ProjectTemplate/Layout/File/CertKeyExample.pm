package Ocean::ProjectTemplate::Layout::File::CertKeyExample;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'server.nopass.key' }

1;

__DATA__
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDPyt/v410xOW8BlfN1wdE7Z23LJ5BCvzRKAhCvsrqEfoxNFeWr
YHw+ghe/mGyG6QG4ewTEoSB1kHaaVt0HKTPFjbRY6Y3DEodP0viw/MuY95IY5J3b
nAQGlLkazHAzF/D2d+OYPoXfuW/4BTHCCLg5TlQS6MfcnlKcA1PRNU1JeQIDAQAB
AoGAXp4QjllHjCyM4Xn4XDyfG5+jHQis5dfO5Yw/MOH/kGlXVZqM9BaBPK1cRwAP
GvdqsyhBKY/9Cct4VhsLlkEqsw1oVRICAnHRqfAvbBmDEVVy+jr501giYNCiy6vD
LTPSL5I2S5te7JN5TnRxjCutv1d+Wcg175/l7AVE1htp6CkCQQD6nRw6Hs8qGIzn
+JtiPJloUn1BEMpQfmX0TlO4VOvidU42tWHC7GOAvPr57r7SvjvRXpkFZgSKgF6s
UmKRTJAPAkEA1EIo6t+M6nBpGiukxWglw4pYwty1LeTo0JAknSZNRiFvA+5bHa1s
EsQYOQ3JQtPtWZELi+sIdi+2N9LswoIF9wJAXFGv6kEbM3ijv3g3VTLZmDJ67ZMP
1CMbz6li8c5mrp9j1oduoe2Oogf7tEIcjWmCg5gDapewKI0tUvFuWfQIRQJBAJ7Z
8LNuoJBnllDurr7KZdDEvg7/jFyPfylvZudxXc2JggLoJKq+Oi6FMTepuKDZ6Dzq
z0Bkoo2IwY9fvK8JDhsCQD9ABpqTmOFUz0QOLRhr0t1H+HKczCDeC2pruD9eaLJ+
q/VJBljD5D2uK6wWvKu+yDf+LCcQL8VATXpyoyLgJKw=
-----END RSA PRIVATE KEY-----
