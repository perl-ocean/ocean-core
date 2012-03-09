package Ocean::LoggerFactory;

use strict;
use warnings;

use Module::Load ();

sub create {
    my ($class, $config) = @_;

    my $logger_class = 
        $class->get_logger_class_by_type( $config->get(log => 'type') );

    Module::Load::load($logger_class);

    my $formatter_class = 
        $class->get_formatter_class_by_type( $config->get(log => 'formatter') );

    Module::Load::load($formatter_class);

    my $formatter = $formatter_class->new;

    my $logger = $logger_class->new(
        config    => $config,
        formatter => $formatter,
    );
    return $logger;
}

my $FORMATTER_CLASS_MAP = {
    'default' => 'Ocean::LogFormatter::Default',
    'color'   => 'Ocean::LogFormatter::Color',
    'simple'  => 'Ocean::LogFormatter::Simple',
};

sub get_formatter_class_by_type {
    my ($class, $type) = @_;
    $type ||= 'default';
    my $formatter_class = $FORMATTER_CLASS_MAP->{$type};
    die sprintf("Unknown log format type '%s'", $type) 
        unless $formatter_class;
    return $formatter_class;
}

my $LOGGER_CLASS_MAP = {
    'warn'   => 'Ocean::Logger::Warn',
    'print'  => 'Ocean::Logger::Print',
    'file'   => 'Ocean::Logger::File',
    'syslog' => 'Ocean::Logger::Syslog',
};

sub get_logger_class_by_type {
    my ($class, $type) = @_;
    my $logger_class = $LOGGER_CLASS_MAP->{$type};
    die sprintf("Unknown logger type '%s'", $type) 
        unless $logger_class;
    return $logger_class;
}

1;
