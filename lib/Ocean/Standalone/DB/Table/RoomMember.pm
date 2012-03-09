package Ocean::Standalone::DB::Table::RoomMember;

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
CREATE TABLE `room_member` (
      `id`        INTEGER PRIMARY KEY
    , `room_id`   INTEGER
    , `username`  TEXT
    ,  UNIQUE(room_id, username)
);

@@ create_index_01.sql
CREATE INDEX room_member_idx_01 ON room_member (room_id);

