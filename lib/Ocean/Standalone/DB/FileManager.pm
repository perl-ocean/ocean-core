package Ocean::Standalone::DB::FileManager;

use strict;
use warnings;

use DBI;
use Ocean::Standalone::DB::Table::Connection;
use Ocean::Standalone::DB::Table::Node;
use Ocean::Standalone::DB::Table::Relation;
use Ocean::Standalone::DB::Table::User;
use Ocean::Standalone::DB::Table::Room;
use Ocean::Standalone::DB::Table::RoomMember;
use Ocean::Standalone::DB::Table::RoomMemberConnection;
use Log::Minimal;

sub TABLE_CLASSES {
    qw(
        Ocean::Standalone::DB::Table::User 
        Ocean::Standalone::DB::Table::Node
        Ocean::Standalone::DB::Table::Connection
        Ocean::Standalone::DB::Table::Relation
        Ocean::Standalone::DB::Table::Room
        Ocean::Standalone::DB::Table::RoomMember
        Ocean::Standalone::DB::Table::RoomMemberConnection
    );
}

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _file => $args{file},
        _dbh  => undef,
    }, $class;
    return $self;
}

sub setup {
    my $self = shift;
    $self->setup_table($_) 
        for TABLE_CLASSES();
}

sub _create_connection {
    my $self = shift;
    my $dbh = DBI->connect(
        sprintf("dbi:SQLite:dbname=%s", $self->{_file}), 
        "", 
        "", 
        {
            AutoCommit => 1, 
            RaiseError => 1,
        }
    ) or die "failed to connect to db $!";
    return $dbh;
}

sub _get_dbh {
    my $self = shift;
    $self->{_dbh} = $self->_create_connection()
        unless $self->{_dbh};
    return $self->{_dbh};
}

sub _execute_sql {
    my ($self, $sql) = @_;

    chomp $sql;
    debugf("<DB> execute SQL: %s", $sql);

    my $dbh = $self->_get_dbh();
    $dbh->do($sql);
}

sub setup_table {
    my ($self, $table_class) = @_;

    chomp $table_class;
    debugf("<DB> start to setup table: %s", $table_class);

    my $table_sql = $table_class->get_create_table_sql();
    my $idx_sqls = $table_class->get_create_index_sql();

    $self->_execute_sql($_) 
        for ($table_sql, @$idx_sqls);
}

sub delete_db {
    my $self = shift;
    unlink $self->{_file} if (-e $self->{_file});
}

sub clear {
    my $self = shift;
    $self->delete_db();
}

1;
