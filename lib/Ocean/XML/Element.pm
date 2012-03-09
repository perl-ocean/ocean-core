package Ocean::XML::Element;

use strict;
use warnings;

use Ocean::Util::XML qw(gen_xml_sig);
use overload 
    '""'     => sub { shift->as_string },
    fallback => 1;

use constant {
    NS        => 0,
    LOCALNAME => 1,
    ATTRS     => 2,
    TEXT      => 3,
    CHILDREN  => 4,
};

sub new {
    my ($class, $ns, $localname, $attrs, $text, $children) = @_;
    my $self = bless [], $class;
    $self->[ NS        ] = $ns;
    $self->[ LOCALNAME ] = $localname;
    $self->[ ATTRS     ] = $attrs    || {};
    $self->[ TEXT      ] = $text     || '';
    $self->[ CHILDREN  ] = $children || {};
    return  $self;
}

sub ns        { $_[0]->[NS]        }
sub localname { $_[0]->[LOCALNAME] }
sub text      { $_[0]->[TEXT]      }
sub attrs     { $_[0]->[ATTRS]     }

sub match {
    my ($self, $ns, $localname) = @_;
    return ($localname eq $self->[LOCALNAME]
         && $ns        eq $self->[NS]
     ) ? 1 : 0;
}

sub get_elements {
    my ($self, $localname) = @_;
    return $self->get_element_ns($self->[NS], $localname);
}

sub get_elements_ns {
    my ($self, $ns, $localname) = @_;
    my $sig = gen_xml_sig($localname, $ns);
    return (exists $self->[CHILDREN]->{$sig})
        ? $self->[CHILDREN]->{$sig} : [];
}

sub append_child {
    my ($self, $elem) = @_;
    my $sig = gen_xml_sig($elem->localname, $elem->ns);
    unless (exists $self->[CHILDREN]->{$sig}) {
        $self->[CHILDREN]->{$sig} = [];
    }
    push(@{ $self->[CHILDREN]->{$sig} }, $elem);
}

sub get_first_element {
    my ($self, $localname) = @_;
    return $self->get_first_element_ns($self->[NS], $localname);
}

sub get_first_element_ns {
    my ($self, $ns, $localname) = @_;
    my $sig = gen_xml_sig($localname, $ns);
    return (exists $self->[CHILDREN]->{$sig})
        ? $self->[CHILDREN]->{$sig}[0] : undef;
}

sub children {
    my $self = shift;
    return values %{ $self->[CHILDREN] };
}

sub attr {
    my ($self, $name, $value) = @_;
    $self->[ATTRS]->{$name} = $value if defined $value;
    return $self->[ATTRS]->{$name};
}

sub remove_attr {
    my ($self, $name) = @_;
    delete $self->[ATTRS]->{$name};
}

sub as_string {
    my ($self, $current_ns) = @_;

    my $str;
    if (defined $current_ns && $current_ns eq $self->[NS]) {
        $str = sprintf q{<%s}, $self->[LOCALNAME];
    } else {
        $str = sprintf q{<%s xmlns="%s"}, 
            $self->[LOCALNAME], $self->[NS];
    }
    $current_ns = $self->[NS];

    my @attr_pairs;
    for my $attr_name ( keys %{ $self->[ATTRS] } ) {
        my $attr_value = $self->attr($attr_name);
        push(@attr_pairs, sprintf(q{%s="%s"}, $attr_name, $attr_value));
    }

    if (@attr_pairs > 0) {
        my $attr_part = join ' ', @attr_pairs;
        $str .= ' ';
        $str .= $attr_part;
    }

    my @children;

    push(@children, $self->[TEXT]) if defined $self->[TEXT];

    for my $child_elements ( values %{ $self->[CHILDREN] } ) {
        for my $child ( @$child_elements ) { 
            push(@children, $child->as_string($current_ns));
        }
    }

    if (@children > 0) {
        $str .= '>';
        $str .= join '', @children;
        $str .= sprintf '</%s>', $self->[LOCALNAME];
    } else {
        $str .= '/>';
    }
    return $str;
}


1;
