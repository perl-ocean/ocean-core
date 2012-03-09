package Ocean::Bootstrap;

use strict;
use warnings;

use Ocean::Config;
use Ocean::Error;
use Ocean::LoggerFactory;

use Log::Minimal;
use Try::Tiny;

sub config_schema { 
    my $class = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Bootstrap::config_schema not implemented}, 
    );
}

sub server_factory {
    my ($class, $config) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Bootstrap::server_factory not implemented}, 
    );
}

sub run {
    my ($class, %args) = @_;

    Ocean::Config->initialize(
        path   => $args{config_file},
        schema => $class->config_schema(),
    );

    my $config = Ocean::Config->instance;
    my $log_level = uc $config->get(log => 'level') || 'INFO';
    local $Log::Minimal::LOG_LEVEL = $log_level;

    # Log::Minimal Debug Setting
    local $ENV{LM_DEBUG} = 1 
        if $log_level eq 'DEBUG';

    my $logger = Ocean::LoggerFactory->create($config);
    $logger->initialize();
    local $Log::Minimal::PRINT = sub { $logger->print(@_) };

    infof("<Server> Loaded config '%s'", $args{config_file});
    debugf("<Server> Log level is set to '%s'", $log_level);

    my $server_factory = $class->server_factory();
    my $server;
    try {
        $server = $server_factory->create_server($config, $args{daemonize});
    } catch {
        my $errmsg = $_->can('message') ? $_->message : "$_";
        critf('<Server> failed initialization: %s', $errmsg);
        return;
    };
    $server->run() if $server;

    $logger->finalize();
}

1;

