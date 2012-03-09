package Ocean::Standalone::DB::Table::RoomMemberConnection;

use strict;
use warnings;

use Data::Section::Simple qw(get_data_section);

sub get_create_table_sql {  get_data_section('create_table.sql') }

sub get_create_index_sql { [ 
    map { get_data_section($_) } 
         qw(create_index_01.sql 
            create_index_02.sql) ] 
}

1;
__DATA__

@@ create_table.sql
CREATE TABLE `room_member_connection` (
      `id`            INTEGER PRIMARY KEY
    , `room_id`       INTEGER
    , `nickname`      TEXT
    , `connection_id` TEXT
    ,  UNIQUE(room_id, nickname)
    ,  UNIQUE(room_id, connection_id)
);

@@ create_index_01.sql
CREATE INDEX room_member_connection_idx_01 ON room_member_connection (room_id);

@@ create_index_02.sql
CREATE INDEX room_member_connection_idx_02 ON room_member_connection (connection_id);

