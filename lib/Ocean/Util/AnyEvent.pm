package Ocean::Util::AnyEvent;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    refresh_write_buffer_memory
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

=head2 METHODS

=head2 refresh_write_buffer_memory

http://subtech.g.hatena.ne.jp/mala/20100114/1263458709

=cut

sub refresh_write_buffer_memory {
    my $handle = shift;
    return unless $handle;
    if (defined $handle->{wbuf} && $handle->{wbuf} eq '') {
        delete $handle->{wbuf};
        $handle->{wbuf} = '';
    }
    if (defined $handle->{_tls_wbuf} && $handle->{_tls_wbuf} eq '') {
        delete $handle->{_tls_wbuf};
        $handle->{_tls_wbuf} = '';
    }
}

1;
