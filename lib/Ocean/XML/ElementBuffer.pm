package Ocean::XML::ElementBuffer;

use strict;
use warnings;

use Log::Minimal;

use Ocean::Error;
use Ocean::Constants::StreamErrorType;
use Ocean::XML::Element;
use Ocean::Util::XML qw(gen_xml_sig);

use constant {
    NS           => 0,
    LOCALNAME    => 1,
    DEPTH        => 2,
    ATTRS        => 3,
    TEXTS        => 4,
    CHILDREN     => 5,
    CHILD_BUFFER => 6,
};

sub new {
    my ($class, $ns, $localname, $depth, $attrs) = @_;
    my $self = bless [], $class;
    $self->[ NS           ] = $ns;
    $self->[ LOCALNAME    ] = $localname;
    $self->[ DEPTH        ] = $depth;
    $self->[ ATTRS        ] = $attrs;
    $self->[ TEXTS        ] = [];
    $self->[ CHILDREN     ] = {};
    $self->[ CHILD_BUFFER ] = undef;
    return $self;
}

sub push_text {
    my ($self, $text) = @_;
    if ($self->[CHILD_BUFFER]) {
        $self->[CHILD_BUFFER]->push_text($text);
    } else {
        push(@{ $self->[TEXTS] }, $text);
    }
}

sub match {
    my ($self, $ns, $localname, $depth) = @_;
    return ($self->[NS]        eq $ns
         && $self->[LOCALNAME] eq $localname
         && $self->[DEPTH]     == $depth
     ) ? 1 : 0;
}

sub start_capturing {
    my ($self, $ns, $localname, $depth, $attrs) = @_;

    if ($self->[CHILD_BUFFER]) {
        $self->[CHILD_BUFFER]->start_capturing($ns, $localname, $depth, $attrs);
    } else {
        unless ($depth == $self->[DEPTH] + 1) {
            debugf("<Stream> <Decoder> Invalid xml element depth");
            Ocean::Error::ProtocolError->throw(
                type => Ocean::Constants::StreamErrorType::INVALID_XML);
        }
        $self->[CHILD_BUFFER] = Ocean::XML::ElementBuffer->new($ns,
            $localname, $depth, $attrs);
    }
}

sub is_capturing {
    my ($self, $ns, $localname, $depth) = @_;
    return 0 unless $self->[CHILD_BUFFER];

    if ($depth == $self->[DEPTH] + 1) {
        return $self->[CHILD_BUFFER]->match($ns, $localname, $depth); 
    } elsif ($depth > $self->[DEPTH] + 1) {
        return $self->[CHILD_BUFFER]->is_capturing($ns, $localname, $depth);
    } else {
        return;
    }
}

sub finish_capturing {
    my ($self, $ns, $localname, $depth) = @_;

    unless ($self->is_capturing($ns, $localname, $depth)) {
        debugf("<Stream> <Decoder> Invalid xml element %s:%s", $ns, $localname);
        Ocean::Error::ProtocolError->throw(
            type => Ocean::Constants::StreamErrorType::INVALID_XML);
    }

    if ($depth == $self->[DEPTH] + 1) {
        my $sig = gen_xml_sig($localname, $ns);
        $self->[CHILDREN]->{$sig} = []
            unless exists $self->[CHILDREN]->{$sig};
        push ( @{ $self->[CHILDREN]->{$sig} },
            $self->[CHILD_BUFFER]->to_element());
        #delete $self->[CHILD_BUFFER];
        $self->[CHILD_BUFFER] = undef;
    } elsif ($depth > $self->[DEPTH] + 1) {
        $self->[CHILD_BUFFER]->finish_capturing($ns, $localname, $depth);
    }

}

sub to_element {
    my $self = shift;
    my $text = ( @{ $self->[TEXTS] } > 0 )
        ? join('', @{ $self->[TEXTS] }) : '';
    return Ocean::XML::Element->new(
        $self->[NS], $self->[LOCALNAME], $self->[ATTRS],
            $text, $self->[CHILDREN]);
}

1;
