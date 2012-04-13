use strict;
use warnings;

use inc::Module::Install;

name 'Ocean';
all_from 'lib/Ocean.pm';

requires(
    'parent'                    => 0.225,
    'Net::SSLeay'               => 1.36,
    'Params::Validate'          => 1.00,
    'XML::Parser::Expat'        => 2.41,
    'Class::Accessor::Fast'     => 0,
    'YAML'                      => 0.77,
    'Kwalify'                   => 0.00,
    'Class::Singleton'          => 1.4,
    'AnyEvent'                  => 6.02,
    'Event'                     => 1.20,
    'XML::Writer'               => 0.612,
    'MIME::Base64'              => 3.13,
    'Digest'                    => 0,
    'Digest::SHA1'              => 2.13,
    'List::MoreUtils'           => 0.33,
    'Scalar::Util'              => 1.23,
    'Try::Tiny'                 => 0.11,
    'Data::Dump'                => 1.19,
    'Data::Visitor::Lite'       => 0.03,
    'Data::Section::Simple'     => 0.0,
    'JSON'                      => 2.53,
    'URI'                       => 1.59,
    'File::Slurp'               => 9999.19,
    'Log::Minimal'              => 0.09,
    'Log::Dispatch'             => 2.29,
    'Log::Dispatch::FileRotate' => 1.19,
    'Sys::Syslog'               => 0.29,
    'Pod::Usage'                => 0,
    'Getopt::Long'              => 0,
    'LWP::UserAgent'            => 0,

    # WebSocket
    'HTTP::Parser::XS'          => 0.14,
    'JSON::XS'                  => 2.32,
    'URI::Escape'               => 0.00,

    # Cluster

    # Cluster::Gearman
    'Gearman::Client'           => 1.11,
    'AnyEvent::Gearman'         => 0.09,

    # Cluster::Kestrell
    #'Cache::Memcached::Fast'    => 0.19,
    #'AnyEvent::Memcached'       => 0.05,

    # Cluster::RabbitMQ
    #'AnyEvent::RabbitMQ'        => '',
    #'Net::RabbitFoot'           => '',

    # Jingle::STUN
    # 'AnyEvent::Handle::UDP'     => 0.032,
    # 'Tie::Hash::Indexed'        => 0.05,
    # 'Authen::SASL::SASLprep'    => 1.01,

    # XMPP XHTML-IM
    'HTML::Scrubber'             => 0.09,

    # DB for Standalone mode
    'DBD::SQLite'               => '',
    'DBI'                       => '',
    'Teng'                      => '',

    # TOOLS
    #'Contextual::Return'    => 0,
    #'Devel::Mallinfo'       => 0,
    #'Module::Depends'       => 0,
    #'Number::Bytes::Human'  => 0,
    #'Devel::Leak::Object'   => 0,
    #'Test::TCP'             => 0,
    #'GTop'                  => 0,
);

tests('t/*.t t/*/*.t t/*/*/*.t');

#author_tests('xt');

test_requires(
    #'Test::Class' => 0,
    'Test::More'                => 0,
    'Protocol::WebSocket'       => 0.00905,
    'Coro'                      => 6.06,
    'TAP::Formatter::JUnit'     => '',
    'Test::LoadAllModules'      => '',
    'TAP::Harness::JUnit'       => '',
);

install_script 'bin/ocean';
install_script 'bin/ocean-standalone';
install_script 'bin/ocean-cluster-frontend';
install_script 'bin/ocean-cluster-backend';
install_script 'bin/ocean-cluster-backend-standalone';

auto_include;
WriteAll;
