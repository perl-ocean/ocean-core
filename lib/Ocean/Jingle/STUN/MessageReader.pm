package Ocean::Jingle::STUN::MessageReader;

use strict;
use warnings;

use bytes ();

use Ocean::Jingle::STUN::ClassType;
use Ocean::Jingle::STUN::MethodType;
use Ocean::Jingle::STUN::AttributeType;
use Ocean::Jingle::STUN::MessageReaderContext;

use Ocean::Jingle::TURN::Attribute::ChannelNumber;
use Ocean::Jingle::TURN::Attribute::Data;

use Try::Tiny;
use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless { 
        _attribute_codec_store => $args{attribute_codec_store}, 
    }, $class;
    return $self;
}

sub read {
    my ($self, $bytes) = @_;

    my $length = bytes::length($bytes);
    unless ($length >= 2) {
        # header not found
        debugf('<MessageReader> @bad_request message header not found');
        return;
    }

    my $head = substr $bytes, 0, 2, '';

    # 0b00 - STUN-formatted message
    if ((vec($head, 0, 8) & 0b11000000) == 0b00000000) {

        my $ctx = Ocean::Jingle::STUN::MessageReaderContext->new;
        $ctx->push_bytes($head);

        my $message_type = vec $head, 0, 16;
        my $class = 
            Ocean::Jingle::STUN::ClassType->classify_by_message_type_field($message_type);
        $ctx->class($class);
        my $method = 
            Ocean::Jingle::STUN::MethodType->classify_by_message_type_field($message_type);
        $ctx->method($method);
        $self->_read_stun_message($ctx, $bytes);

        return $ctx;
    }
    # 0b01 ChannelData message
    elsif ((vec($head, 0, 8) & 0b11000000) == 0b01000000) {
        my $channel_number = vec $head, 0, 16;
        if (   $channel_number >= 0x4000
            && $channel_number <= 0x7fff) {
            my $ctx = $self->_read_channel_data($channel_number, $bytes);
            return $ctx;
        } else {
            debugf('<MessageReader> @bad_request invalid channel data message');
            return;
        }
    }
    else {
        debugf('<MessageReader> @bad_request unknown message type');
        return;
    }
}

sub _read_stun_message {
    my ($self, $ctx, $bytes) = @_;

    my $rest_length = bytes::length($bytes);
    unless ($rest_length >= 18) { # 18 = 2(length) + 4(magic cookie) + 12(transaction_id)
        debugf('<MessageReader> @bad_request length not enough for message header');
        return;
    }

    # read length
    my $body_length_bytes = substr $bytes, 0, 2, '';
    $ctx->push_bytes($body_length_bytes);
    my $body_length = unpack('n', $body_length_bytes);
    $ctx->length($body_length);

    # check magic cookie
    my $cookie_bytes = substr $bytes, 0, 4, '';
    $ctx->push_bytes($cookie_bytes);
    my $cookie = unpack('H8', $cookie_bytes);
    if ($cookie ne '2112a442') {
        debugf('<MessageReader> @bad_request magic cookie not found');
        return;
    }

    my $transaction_id_bytes = substr $bytes, 0, 12, '';
    $ctx->push_bytes($transaction_id_bytes);
    my $transaction_id = unpack('H24', $transaction_id_bytes);
    $ctx->transaction_id($transaction_id);

    my $read_length = 0;
    $rest_length -= 18;

    while ($read_length < $body_length) {
        unless ($rest_length >= 4) {
            debugf('<MessageReader> @bad_request length not enough for attribute header');
            return;
        }

        my $attr_type_bytes   = substr $bytes, 0, 2, '';
        my $attr_length_bytes = substr $bytes, 0, 2, '';
        $rest_length -= 4;

        my $attr_type = 
            Ocean::Jingle::STUN::AttributeType->classify_by_bitfield(
                vec($attr_type_bytes, 0, 16));

        my $attr_length = unpack('n', $attr_length_bytes);

        # padding
        my $mod = $attr_length % 4; 
        my $padded_length = ($mod == 0) 
            ? $attr_length
            : $attr_length + (4 - $mod);
        
        unless ($rest_length >= $padded_length) {
            debugf('<MessageReader> @bad_request length not enough for attribute value');
            return;
        }

        my $attr_body = substr $bytes, 0, $padded_length, '';
        $rest_length -= $padded_length;

        unless ($attr_type) {
            debugf('<MessageReader> @bad_request unknown attribute type');
            $ctx->add_unknown_attribute($attr_type_bytes);

            $ctx->push_bytes($attr_type_bytes);
            $ctx->push_bytes($attr_length_bytes);
            $ctx->push_bytes($attr_body);
            $read_length += (4 + $padded_length);
            next;
        }

        my $attr_reader = 
            $self->{_attribute_codec_store}->get_codec($attr_type);

        unless ($attr_reader) {
            debugf('<MessageReader> unsupported attribute header: %s', $attr_type);
            $ctx->add_unknown_attribute($attr_type_bytes);
        } else {
            if ($attr_reader->check_order($ctx)) {
                my $attribute = 
                    $attr_reader->decode($ctx, $attr_length, $attr_body);
                unless ($attribute) {
                    debugf('<MessageReader> @bad_request invalid attribute: %s', $attr_type);
                    return;
                }
                $ctx->add_attribute($attr_type, $attribute);
            } else {
                debugf('<MessageReader> @bad_request invalid attribute order: %s', $attr_type);
                # ignore
                $ctx->push_bytes($attr_type_bytes);
                $ctx->push_bytes($attr_length_bytes);
                $ctx->push_bytes($attr_body);
                $read_length += (4 + $padded_length);
                next;
            }
        }

        $ctx->push_bytes($attr_type_bytes);
        $ctx->push_bytes($attr_length_bytes);
        $ctx->push_bytes($attr_body);
        $read_length += (4 + $padded_length);
    }

    return $ctx;
}

sub _read_channel_data {
    my ($self, $channel_number, $bytes) = @_;

    my $rest_length = bytes::length($bytes);
    if ($rest_length < 2) {
        debugf('<MessageReader> @bad_request length not enough for channel data message header');
        return;
    }
    my $data_length = pack('n', substr($bytes, 0, 2, ''));
    $rest_length -= 2;
    if ($rest_length < $data_length) {
        debugf('<MessageReader> @bad_request length not enough for channel data message value');
        return;
    }
    my $data = '';
    $data = substr $bytes, 0, $data_length, ''
        if $data_length > 0;

    my $ctx = Ocean::Jingle::STUN::MessageReaderContext->new;
    $ctx->class(Ocean::Jingle::STUN::ClassType::INDICATION);
    $ctx->method(Ocean::Jingle::STUN::MethodType::SEND);
    my $channel_number_attr = Ocean::Jingle::TURN::Attribute::ChannelNumber->new;
    $channel_number_attr->set(number => $channel_number);
    $ctx->add_attribute(
        Ocean::Jingle::STUN::AttributeType::CHANNEL_NUMBER,
        $channel_number_attr);
    my $data_attr = Ocean::Jingle::TURN::Attribute::Data->new;
    $data_attr->set(data => $data);
    $ctx->add_attribute(
        Ocean::Jingle::STUN::AttributeType::DATA,
        $data_attr);

    return $ctx;
}

1;
