use strict;
use warnings;

use Test::More; 

use Ocean::Config;
use Ocean::Config::Schema;
use Try::Tiny;
use Cwd;

my $instance;
my $err;
try {
    $instance = Ocean::Config->instance;
} catch {
   $err = "$_"
};
is($err, 'Config: file path is not set');
ok(!$instance);


my $filepath;
$filepath = q{unknown};
try {
    Ocean::Config->initialize(
        path   => $filepath,
        schema => Ocean::Config::Schema->config,
    );
    Ocean::Config->instance;
} catch {
    $err = "$_";
};

is($err, q{Config: couldn't open file - unknown});

sub validate_config_file_not_ok {
    my $filepath = shift;
    my $instance;
    $err = '';
    try {
        Ocean::Config->initialize(
            path   => $filepath,
            schema => Ocean::Config::Schema->config,
        );
        $instance = Ocean::Config->instance;
    } catch {
        $err = "$_";
    };
    ok(!$instance, $filepath);
    ok($err, $filepath) #, 'Config: Instance is not set yet');
}

&validate_config_file_not_ok(q{t/data/config/test1.yml});

sub validate_config_file_ok {
    my $filepath = shift;
    my $instance; 
    $err = '';
    try {
        Ocean::Config->initialize(
            path   => $filepath,
            schema => Ocean::Config::Schema->config,
        );
        $instance = Ocean::Config->instance;
    } catch {
        $err = "$_";
    };
    is($err, q{});
    ok($instance);
}

&validate_config_file_ok(q{t/data/config/test2.yml});
&validate_config_file_ok(q{t/data/config/test3.yml});

is(Ocean::Config->instance->get('server','domain'), 'xmpp.example.org');
is(Ocean::Config->instance->get('server','port'), 5222);
is(Ocean::Config->instance->get('server','backlog'), 5);
is(Ocean::Config->instance->get('server','max_connection'), 100);

is(Ocean::Config->instance->get('server','timeout'), '10');
is(Ocean::Config->instance->get('server', 'max_read_buffer'), '1000');

my $mechs = Ocean::Config->instance->get('sasl', 'mechanisms');
is(scalar @$mechs, 2);
is($mechs->[0], 'PLAIN');
is($mechs->[1], 'X-OAUTH');

is(Ocean::Config->instance->get('tls','ca_file'), '/dev/null');
is(Ocean::Config->instance->get('handler', 'my_handler_param1'), 100);
is(Ocean::Config->instance->get('handler', 'my_handler_param2'), 200);

done_testing();
