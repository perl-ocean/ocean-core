package Ocean::Standalone::DB::Table::Connection;

use strict;
use warnings;

use Data::Section::Simple qw(get_data_section);

sub get_create_table_sql {  get_data_section('create_table.sql') }

sub get_create_index_sql { [ 
    map { get_data_section($_) } 
        qw(create_index_01.sql create_index_02.sql) ] 
}

1;
__DATA__

@@ create_table.sql
CREATE TABLE `connection` (
      `id`              INTEGER PRIMARY KEY
    , `user_id`         INTEGER
    , `username`        TEXT
    , `resource`        TEXT
    , `presence_show`   TEXT DEFAULT ''
    , `presence_status` TEXT DEFAULT ''
    , `node_id`         TEXT
    ,  UNIQUE(user_id, resource)
);

@@ create_index_01.sql
CREATE INDEX connection_idx_01 ON connection (username);

@@ create_index_02.sql
CREATE INDEX connection_idx_02 ON connection (username, resource);

