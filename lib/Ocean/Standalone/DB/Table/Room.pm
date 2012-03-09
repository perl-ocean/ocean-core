package Ocean::Standalone::DB::Table::Room;

use strict;
use warnings;

use Data::Section::Simple qw(get_data_section);

sub get_create_table_sql {  get_data_section('create_table.sql') }

sub get_create_index_sql { [ ] }

1;
__DATA__

@@ create_table.sql
CREATE TABLE `room` (
      `id`       INTEGER PRIMARY KEY
    , `name`     TEXT
    , `nickname` TEXT
    , `subject`  TEXT
    ,  UNIQUE(name)
);

