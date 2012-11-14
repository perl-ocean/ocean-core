package Ocean::Standalone::DB::Table::User;

use strict;
use warnings;

use Data::Section::Simple qw(get_data_section);

sub get_create_table_sql {  get_data_section('create_table.sql') }

sub get_create_index_sql { [ 
    map { get_data_section($_) } 
        qw(create_index_01.sql) ] 
}

1;
__DATA__

@@ create_table.sql
CREATE TABLE `user` (
      `id`               INTEGER PRIMARY KEY
    , `password`         TEXT
    , `oauth_token`      TEXT
    , `username`         TEXT
    , `nickname`         TEXT
    , `profile_img_b64`  TEXT
    , `profile_img_hash` TEXT
    , `profile_img_url`  TEXT
    , `is_echo`          INTEGER
    , `cookie`           TEXT
    ,  UNIQUE(username)
);

@@ create_index_01.sql
CREATE INDEX user_idx_01 ON user (cookie);

