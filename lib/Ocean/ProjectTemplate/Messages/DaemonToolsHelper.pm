package Ocean::ProjectTemplate::Messages::DaemonToolsHelper;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Messages';

use Data::Section::Simple qw(get_data_section);

sub get_message_of {
    my ($self, $type) = @_;
    return get_data_section($type);
}

1;
__DATA__
@@ logo.txt
      ___           ___           ___           ___           ___     
     /\  \         /\  \         /\  \         /\  \         /\__\    
    /::\  \       /::\  \       /::\  \       /::\  \       /::|  |   
   /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/\:\  \     /:|:|  |   
  /:/  \:\  \   /:/  \:\  \   /::\~\:\  \   /::\~\:\  \   /:/|:|  |__ 
 /:/__/ \:\__\ /:/__/ \:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\ /:/ |:| /\__\
 \:\  \ /:/  / \:\  \  \/__/ \:\~\:\ \/__/ \/__\:\/:/  / \/__|:|/:/  /
  \:\  /:/  /   \:\  \        \:\ \:\__\        \::/  /      |:/:/  / 
   \:\/:/  /     \:\  \        \:\ \/__/        /:/  /       |::/  /  
    \::/  /       \:\__\        \:\__\         /:/  /        /:/  /   
     \/__/         \/__/         \/__/         \/__/         \/__/    

@@ hello_message.txt
This is a daemontools helper script.
This program generates structured directory and files under 'asset' directory for you to setup daemontools service.
Please answer for some questions.

@@ bye_message.txt
Done.
Now, you can create symbolic link like as follows,
ln -s <: $layout.relative_path_for('daemontools_service_dir') :> /service

