package Ocean::ProjectTemplate::Layout::File::Config::Fixture;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'fixture.yml' }

1;
__DATA__
users:
    - id:               user_01
      username:         kusanagi
      nickname:         Kusanagi
      password:         foobar
      oauth_token:      111111
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example01') :>)__
    - id:               user_02 
      username:         aramaki
      nickname:         Aramaki
      password:         foobar
      oauth_token:      222222
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example02') :>)__
    - id:               user_03 
      username:         batou
      nickname:         Batou
      password:         foobar
      oauth_token:      333333
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example03') :>)__
    - id:               user_04 
      username:         togusa
      nickname:         Togusa
      password:         foobar
      oauth_token:      444444
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example04') :>)__
    - id:               user_05 
      username:         ishikawa
      nickname:         Ishikawa
      password:         foobar
      oauth_token:      555555
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example05') :>)__
    - id:               user_06 
      username:         saito
      nickname:         Saito
      password:         foobar
      oauth_token:      666666
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example06') :>)__
    - id:               user_07 
      username:         paz
      nickname:         Paz
      password:         foobar
      oauth_token:      777777
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example07') :>)__
    - id:               user_08 
      username:         borma
      nickname:         Borma
      password:         foobar
      oauth_token:      888888
      profile_img_file: __path_to(<: $layout.relative_path_for('img_example08') :>)__
relations:
    - follower: user_01
      followee: user_02
    - follower: user_01
      followee: user_03
    - follower: user_01
      followee: user_04
    - follower: user_01
      followee: user_05
    - follower: user_01
      followee: user_06
    - follower: user_01
      followee: user_07
    - follower: user_01
      followee: user_08

    - follower: user_02
      followee: user_01
    - follower: user_02
      followee: user_03
    - follower: user_02
      followee: user_04
    - follower: user_02
      followee: user_05
    - follower: user_02
      followee: user_06
    - follower: user_02
      followee: user_07
    - follower: user_02
      followee: user_08

    - follower: user_03
      followee: user_01
    - follower: user_03
      followee: user_02
    - follower: user_03
      followee: user_04
    - follower: user_03
      followee: user_05
    - follower: user_03
      followee: user_06
    - follower: user_03
      followee: user_07
    - follower: user_03
      followee: user_08

    - follower: user_04
      followee: user_01
    - follower: user_04
      followee: user_02
    - follower: user_04
      followee: user_03
    - follower: user_04
      followee: user_05
    - follower: user_04
      followee: user_06
    - follower: user_04
      followee: user_07
    - follower: user_04
      followee: user_08

    - follower: user_05
      followee: user_01
    - follower: user_05
      followee: user_02
    - follower: user_05
      followee: user_03
    - follower: user_05
      followee: user_04
    - follower: user_05
      followee: user_06
    - follower: user_05
      followee: user_07
    - follower: user_05
      followee: user_08

    - follower: user_06
      followee: user_01
    - follower: user_06
      followee: user_02
    - follower: user_06
      followee: user_03
    - follower: user_06
      followee: user_04
    - follower: user_06
      followee: user_05
    - follower: user_06
      followee: user_07
    - follower: user_06
      followee: user_08

    - follower: user_07
      followee: user_01
    - follower: user_07
      followee: user_02
    - follower: user_07
      followee: user_03
    - follower: user_07
      followee: user_04
    - follower: user_07
      followee: user_05
    - follower: user_07
      followee: user_06
    - follower: user_07
      followee: user_08

    - follower: user_08
      followee: user_01
    - follower: user_08
      followee: user_02
    - follower: user_08
      followee: user_03
    - follower: user_08
      followee: user_04
    - follower: user_08
      followee: user_05
    - follower: user_08
      followee: user_06
    - follower: user_08
      followee: user_07

