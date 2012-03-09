package Ocean::Standalone::DB::Table::Relation;

use strict;
use warnings;

use Data::Section::Simple qw(get_data_section);

sub get_create_table_sql { get_data_section('create_table.sql') }

sub get_create_index_sql { [ 
    map { get_data_section($_) } 
        qw(create_index_01.sql create_index_02.sql) 
] }

1;
__DATA__

@@ create_table.sql
CREATE TABLE `relation` (
      `id` INTEGER PRIMARY KEY
    , `follower_id` INTEGER
    , `followee_id` INTEGER
    ,  UNIQUE(follower_id, followee_id)
);

@@ create_index_01.sql
CREATE INDEX relation_idx_01 ON relation (follower_id);

@@ create_index_02.sql
CREATE INDEX relation_idx_02 ON relation (followee_id);

