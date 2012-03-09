package Ocean::Util::XML;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    gen_xml_sig
    escape_xml_char
    unescape_xml_char
    filter_xml_chars
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub gen_xml_sig {
    sprintf q{%s__%s}, $_[0], $_[1];
}

# borrowed from AnyEvent::XMPP::Util
sub filter_xml_chars {
    my $str = shift;
    $str =~ s/[^\x{9}\x{A}\x{D}\x{20}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFFFF}]+//g;
    return $str;
}

sub escape_xml_char {
    my $str = shift;
    $str =~ s!\&!&amp;!g;
    $str =~ s!\<!&lt;!g;
    $str =~ s!\>!&gt;!g;
    $str =~ s!\"!&quot;!g;
    $str =~ s!\'!&#39;!g;
    return $str;
}

sub unescape_xml_char {
    my $str = shift;
    $str =~ s!\&lt\;!<!g;
    $str =~ s!\&gt\;!>!g;
    $str =~ s!\&quot\;!"!g;
    $str =~ s!\&\#39\;!'!g;
    $str =~ s!\&amp\;!&!g;
    return $str;
}

1;

=head1 NAME

Ocean::Util::XML - utility for XML decoder/encoder

=head1 SYNOPSIS

    use Ocean::StreamComponent::IO::Decoder::Default::Util qw(escape_xml_char);

    my $escaped = escape_xml_char($string);

=head1 DESCRIPTION

Utility for XML decoder/encoder

=head1 METHODS

=head2 gen_xml_sig($localname, $ns)

Generate unique signature for namespace and localname.

=head2 escape_xml_char($string)

Escape xml characters

=head2 unescape_xml_char($string)

Unescape xml characters

=head1 AUTHOR

Lyo Kato, E<lt>lyo.kato@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Lyo Kato

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

