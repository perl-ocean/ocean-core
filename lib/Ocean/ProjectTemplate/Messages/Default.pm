package Ocean::ProjectTemplate::Messages::Default;

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
Welcome!
This is a template generator program for your new project.
Please answer for some questions.

@@ bye_message.txt
Completed to build your initial project files and directories.
Enjoy!
