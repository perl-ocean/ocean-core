package Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Config;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'ocean-stun.yml'        }

1;
__DATA__
---
server:
  domain: xmpp.example.org
  host: 192.168.0.1
  port: 3478
  receive_size: 1500
  pid_file: __path_to(<: $layout.relative_path_for('run_dir') :>/ocean_stun.pid)__
  context_class: <: $context.get('context_class') :>

#tcp:
#  port: 3479
#  secure_port: 5349
#  backlog: 1024
#  max_connection: 100000
#  timeout: 300
#  max_read_buffer: 10000

log:
  type: print
  formatter: color
  level: info
  filepath: __path_to(<: $layout.relative_path_for('log_dir') :>/ocean_stun.log)__

#tls:
#  cert_file: __path_to(<: $layout.relative_path_for('cert_pem') :>)__
#  key_file: __path_to(<: $layout.relative_path_for('cert_key') :>)__
#  cipher_list: ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP:+eNULL

