package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Config::Default;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'ocean-cluster.yml' }

1;
__DATA__
worker:
  max_workers: 1
  node_inboxes:
    - node_id: xmpp00
      address: 192.168.84.70:7002
    - node_id: websocket00
      address: 192.168.84.70:7003
  broker_servers:
    - 192.168.84.70:7001
  queue_name: ocean_default
  context_class: <: $context.get('context_class') :>

event_handler:
  worker:     <: $context.get('handler_class') :>::Worker
  node:       <: $context.get('handler_class') :>::Node
  authen:     <: $context.get('handler_class') :>::Authen
  connection: <: $context.get('handler_class') :>::Connection
  message:    <: $context.get('handler_class') :>::Message
  people:     <: $context.get('handler_class') :>::People
  pubsub:     <: $context.get('handler_class') :>::PubSub
  room:       <: $context.get('handler_class') :>::Room
  p2p:        <: $context.get('handler_class') :>::P2P

log:
  type: print
  level: info
  formatter: color
  filepath: __path_to(<: $layout.relative_path_for('log_dir') :>/ocean.log)__

muc:
  domain: muc.xmpp.example.org

handler:
  db_file_path: __path_to(<: $layout.relative_path_for('db_dir') :>/database.db)__
  my_handler_param1: 100
  my_handler_param2: 200
