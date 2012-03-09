package Ocean::Standalone::Fixture::Schema::Default;

use strict;
use warnings;

sub config {
    my $schema = {
        type => 'map', 
        required => 1,
        mapping => {
            users => {
                type => 'seq',
                required => 1,
                sequence  => [
                    {
                        type => 'map',
                        required => 1,
                        mapping => {
                            id                => { type => 'str', required => 1 }, 
                            username          => { type => 'str', required => 1 }, 
                            nickname          => { type => 'str', required => 1 }, 
                            password          => { type => 'str', required => 1 }, 
                            cookie            => { type => 'str'  }, 
                            is_echo           => { type => 'bool' },
                            profile_img_url   => { type => 'str'  }, 
                            profile_img_file  => { type => 'str'  }, 
                            profile_img_b64   => { type => 'str'  }, 
                            profile_img_hash  => { type => 'str'  }, 
                        }
                    },
                ],
            },
            relations => {
                type => 'seq',
                sequence => [
                    {
                        type => 'map',
                        required => 1,
                        mapping => {
                            follower => { type => 'str', required => 1 }, 
                            followee => { type => 'str', required => 1 }, 
                        }
                    },
                ],
            },
        },
    };
    return $schema;
}

1;
