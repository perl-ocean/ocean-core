package Ocean::Util::Image;

use strict;
use warnings;

use base 'Exporter';

use LWP::UserAgent;
use HTTP::Request;
use Carp ();
use Digest::SHA1 qw(sha1_hex);
use MIME::Base64 qw(encode_base64);

our %EXPORT_TAGS = (all => [qw(
    download
    get_image_data_of_url
    get_image_data_of_file
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub get_image_data_of_file {
    my $path = shift;
    open my $fh, '<', $path 
        or Carp::croak "Failed to open image file: $path";
    my $img = do { local $/; <$fh> };
    return {
        b64  => encode_base64($img), 
        hash => sha1_hex($img),
    };
}

sub get_image_data_of_url {
    my $url = shift;
    my $img = download($url);
    return {
        b64  => encode_base64($img), 
        hash => sha1_hex($img),
    };
}

sub download {
    my $url = shift;

    my $agent = LWP::UserAgent->new;
    my $req = HTTP::Request->new( GET => $url );
    my $res = $agent->request($req);

    die sprintf("Failed to download '%s'", $url) 
        unless $res->is_success;

    return $res->content;
}

1;
