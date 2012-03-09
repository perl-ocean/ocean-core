package Ocean::Standalone::DB::Table::Node;

use strict;
use warnings;

use Data::Section::Simple qw(get_data_section);

sub get_create_table_sql {  get_data_section('create_table.sql') }

sub get_create_index_sql { [ ] }

1;
__DATA__

@@ create_table.sql
CREATE TABLE `node` (
      `node_id`                    VARCHAR(20) PRIMARY KEY
    , `node_host`                  TEXT
    , `node_port`                  TEXT
    , `inbox_host`                 TEXT
    , `inbox_port`                 TEXT
    , `total_connection_counter`   INTEGER DEFAULT 0
    , `current_connection_counter` INTEGER DEFAULT 0
    , `created_at`                 TIMESTAMP 
    , `updated_at`                 TIMESTAMP
    ,  UNIQUE(node_host, node_port)
);

