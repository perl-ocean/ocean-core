package Ocean::Standalone::DB::Schema;

use strict;
use warnings;

use Teng::Schema::Declare;

table {
    name 'user';
    pk 'id';
    columns qw(
        id 
        password
        username
        nickname
        oauth_token
        profile_img_b64
        profile_img_hash
        profile_img_url
        is_echo
        cookie
    );
};

table {
    name 'connection';
    pk 'id';
    columns qw(
        id
        user_id
        username
        resource
        presence_show
        presence_status
        node_id
    );
};

table {
    name 'relation';
    pk 'id';
    columns qw(
        id
        follower_id
        followee_id
    );
};

table {
    name 'room';
    pk 'id';
    columns qw(
        id
        name
        subject 
        nickname
    );
};

table {
    name 'room_member';
    pk 'id';
    columns qw(
        id
        room_id
        username
    );
};

table {
    name 'room_member_connection';
    pk 'id';
    columns qw(
        id
        room_id
        nickname
        connection_id
    );
};

table {
    name 'node';
    pk 'node_id';
    columns qw(
        node_host 
        node_port
        inbox_host
        inbox_port
        total_connection_counter
        current_connection_counter
        created_at
        updated_at
    );
};

1;
