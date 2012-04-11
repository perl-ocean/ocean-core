package Ocean::Jingle::TURN::AllocationID::FiveTuple;

use strict;
use warnings;

use parent 'Ocean::Jingle::TURN::AllocationID';
use Digest::SHA1;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _client_ip_address => $args{client_ip_address}, 
        _client_port       => $args{client_port}, 
        _server_ip_address => $args{server_ip_address}, 
        _server_port       => $args{server_port}, 
        _protocol          => $args{protocol},
    }, $class;
    return $self;
}

sub as_string {
    my $self = shift;
    return Digest::SHA1::sha1_hex( join(':', 
        $self->{_client_ip_address}, 
        $self->{_client_port}, 
        $self->{_server_ip_address}, 
        $self->{_server_port}, 
        $self->{_protocol}, 
    ) );
}

1;
