package Ocean::Jingle::STUN::MessageBuilder;

use strict;
use warnings;

use Ocean::Jingle::STUN::AttributeType qw(
    MESSAGE_INTEGRITY 
    FINGERPRINT 
);
use Ocean::Jingle::STUN::ClassType;
use Ocean::Jingle::STUN::MethodType;
use Ocean::Jingle::STUN::MessageBuilderContext;
use Ocean::Jingle::STUN::Util;

use Tie::Hash::Indexed;

use bytes ();

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _class                 => $args{class},    
        _method                => $args{method},
        _transaction_id        => $args{transaction_id},
        _use_fingerprint       => $args{use_fingerprint},
        _attribute_codec_store => $args{attribute_codec_store},
        _signer                => $args{signer},
        _attributes            => undef,
        _padding_byte          => $args{padding_byte} || "\x00",
    }, $class;
    tie my %attrs, 'Tie::Hash::Indexed';
    $self->{_attributes} = \%attrs;
    return $self;
}

sub add_attribute {
    my ($self, $attribute) = @_;
    $self->{_attributes}{$attribute->type} = $attribute;
}

sub build {
    my $self = shift;

    my $message_type_field = 
        $self->_build_message_type_field(
            $self->{_class}, $self->{_method});

    my $transaction_id = $self->{_transaction_id};

    delete $self->{_attributes}{MESSAGE_INTEGRITY};
    delete $self->{_attributes}{FINGERPRINT};

    my $ctx = Ocean::Jingle::STUN::MessageBuilderContext->new({
        class          => $self->{_class},
        method         => $self->{_method},
        transaction_id => $transaction_id,
    });

    my $body_bytes = '';
    for my $attr_name ( keys %{ $self->{_attributes} } ) {
        my $attr = $self->{_attributes}{$attr_name};
        my $attr_codec = 
            $self->{_attribute_codec_store}->get_codec($attr_name);
        unless ($attr_codec) {
            die "unknown attribute, $attr_name";
        }
        my $attr_body_bytes = $attr_codec->encode($ctx, $attr);
        $body_bytes .= pack('n', 
            Ocean::Jingle::STUN::AttributeType->get_attribute_bytes(
                $attr_name));
        my $attr_body_length = bytes::length($attr_body_bytes);
        $body_bytes .= pack('n', $attr_body_length);
        $body_bytes .= $attr_body_bytes;

        # padding
        my $mod = $attr_body_length % 4;
        $body_bytes .= $self->{_padding_byte} x (4 - $mod) if $mod != 0;
    }

    my $body_length = bytes::length($body_bytes);

    if ($self->{_signer}) {
        $body_length += 24;
        my $bytes = pack('nnH8H24',
            $message_type_field,
            $body_length,
            '2112a442',
            $self->{_transaction_id});
        $bytes .= $body_bytes;
        my $hash = $self->{_signer}->sign($bytes);
        $body_bytes .= pack('nn',
            Ocean::Jingle::STUN::AttributeType->get_attribute_bytes(MESSAGE_INTEGRITY), 
            20,
        );
        $body_bytes .= $hash;
    }

    if ($self->{_use_fingerprint}) {
        $body_length += 8;
        my $bytes = pack('nnH8H24',
            $message_type_field,
            $body_length,
            '2112a442',
            $self->{_transaction_id});
        $bytes .= $body_bytes;
        my $crc = Ocean::Jingle::STUN::Util::calc_fingerprint($bytes);
        $body_bytes .= pack('nnN',
            Ocean::Jingle::STUN::AttributeType->get_attribute_bytes(FINGERPRINT), 
            4,
            $crc ^ 0x5354554e
        );
    }

    my $header_bytes = pack('nnH8H24',
        $message_type_field,
        $body_length,
        '2112a442',
        $self->{_transaction_id});

    return $header_bytes . $body_bytes;
}

sub _build_message_type_field {
    my ($self, $class, $method) = @_;
    my $class_bits  = Ocean::Jingle::STUN::ClassType->get_class_bits($class);
    my $method_bits = Ocean::Jingle::STUN::MethodType->get_method_bits($method);
    return $class_bits | $method_bits;
}

1;
