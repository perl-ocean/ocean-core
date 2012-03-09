package Ocean::Util::Roster;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    need_change_for_outbound_subscribe
    need_change_for_outbound_subscribed
    need_change_for_outbound_unsubscribe
    need_change_for_outbound_unsubscribed
    need_change_for_inbound_subscribe
    need_change_for_inbound_subscribed
    need_change_for_inbound_unsubscribe
    need_change_for_inbound_unsubscribed
    change_for_outbound_subscribe
    change_for_outbound_subscribed
    change_for_outbound_unsubscribe
    change_for_outbound_unsubscribed
    change_for_inbound_subscribe
    change_for_inbound_subscribed
    change_for_inbound_unsubscribe
    change_for_inbound_unsubscribed
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub need_change_for_outbound_subscribe {
    my ($item) = @_;
    return ((not $item->is_pending_out)
        && ($item->subscription eq 'none'
         || $item->subscription eq 'from')) ? 1 : 0;
}

sub change_for_outbound_subscribe {
    my ($item) = @_;
    $item->add_pending_out();
}

sub need_change_for_inbound_subscribe {
    my ($item) = @_;
    return ((not $item->is_pending_in)
        && ($item->subscription eq 'none'
         || $item->subscription eq 'to')) ? 1 : 0;
}

sub change_for_inbound_subscribe {
    my ($item) = @_;
    $item->add_pending_in();
}

sub need_change_for_outbound_subscribed {
    my ($item) = @_;
    return ($item->is_pending_in
        && ($item->subscription eq 'none'
         || $item->subscription eq 'to')) ? 1 : 0;
}

sub change_for_outbound_subscribed {
    my ($item) = @_;
    $item->remove_pending_in();
    if ($item->subscription eq 'to') {
        $item->subscription('both');
    }
    if ($item->subscription eq 'none') {
        $item->subscription('from');
    }
}

sub need_change_for_inbound_subscribed {
    my ($item) = @_;
    return ($item->is_pending_out
        && ($item->subscription eq 'from'
         || $item->subscription eq 'none')) ? 1 : 0;
}

sub change_for_inbound_subscribed {
    my ($item) = @_;
    $item->remove_pending_out();
    if ($item->subscription eq 'from') {
        $item->subscription('both');
    }
    if ($item->subscription eq 'none') {
        $item->subscription('to');
    }
}

sub need_change_for_outbound_unsubscribe {
    my ($item) = @_;
    return ($item->is_pending_out
         || $item->subscription eq 'both'
         || $item->subscription eq 'to') ? 1 : 0;
}

sub change_for_outbound_unsubscribe {
    my ($item) = @_;
    if ($item->is_pending_out) {
        $item->remove_pending_out();
    }
    if ($item->subscription eq 'both') {
        $item->subscription('from');
    }
    if ($item->subscription eq 'to') {
        $item->subscription('none');
    }
}

sub need_change_for_inbound_unsubscribe {
    my ($item) = @_;
    return  ($item->is_pending_in
          || $item->subscription eq 'from'
          || $item->subscription eq 'both') ? 1 : 0;
}

sub change_for_inbound_unsubscribe {
    my ($item) = @_;
    if ($item->is_pending_in) {
        $item->remove_pending_in();
    }
    if ($item->subscription eq 'from') {
        $item->subscription('none');
    }
    if ($item->subscription eq 'both') {
        $item->subscription('to');
    }
}

sub need_change_for_outbound_unsubscribed {
    my ($item) = @_;
    return  ($item->is_pending_in
          || $item->subscription eq 'from'
          || $item->subscription eq 'both') ? 1 : 0;
}

sub change_for_outbound_unsubscribed {
    my ($item) = @_;
    if ($item->is_pending_in) {
        $item->remove_pending_in();
    }
    if ($item->subscription eq 'from') {
        $item->subscription('none');
    }
    if ($item->subscription eq 'both') {
        $item->subscription('to');
    }
}

sub need_change_for_inbound_unsubscribed {
    my ($item) = @_;
    return ($item->is_pending_out
         || $item->subscription eq 'both'
         || $item->subscription eq 'to') ? 1 : 0;
}

sub change_for_inbound_unsubscribed {
    my ($item) = @_;
    if ($item->is_pending_out) {
        $item->remove_pending_out();
    }
    if ($item->subscription eq 'both') {
        $item->subscription('from');
    }
    if ($item->subscription eq 'to') {
        $item->subscription('none');
    }
}

=head1 AUTHOR

Lyo Kato, C<lyo.kato _at_ gmail.com>

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
