package Ocean::ProjectTemplate::Layout::File;

use strict;
use warnings;

use Ocean::Error;

sub new { bless {}, $_[0] }

sub is_executable  { 0 }
sub is_simple_text { 0 }
sub is_binary      { 0 }

sub template { 
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::Layout::File::template}, 
    );
}

sub default_name { 
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::Layout::File::default_name}, 
    );
}

1;
