package Ocean::ServerComponent::Daemonizer::Default;

use strict;
use warnings;

use parent 'Ocean::ServerComponent::Daemonizer';
use POSIX;
use Carp ();
use File::Slurp;
use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _pid_file => $args{pid_file}, 
    }, $class;
    return $self;
}

sub initialize {
    my $self = shift;
    $self->_check_pid_file();
    $self->_daemonize();
    $self->_write_pid_file();
}

sub finalize {
    my $self = shift;
    $self->_remove_pid_file();
}

sub _check_pid_file {
    my $self = shift;
    if (-e $self->{_pid_file} && -f _) {
        if (-s _ && -r _) {
            my $pid = $self->_read_pid_file();
            if ($pid && kill(0, $pid)) {
                die sprintf(
                        q{ocean is already running with pid "%s"}, 
                        $pid) . "\n"
                    . "execute 'oceanstop'\n";
            } else {
                die sprintf(q{found pid-file "%s"}, $self->{_pid_file})
                    . "\n"
                    . "but the process is not found.\n"
                    . "check your situation and if there's no problem,\n"
                    . sprintf(q{remove "%s"}, $self->{_pid_file}) . "\n";

            }
        } else {
            die sprintf(q{found pid-file "%s"}, $self->{_pid_file})
                . "\n"
                . "but it's empty or can't be read.\n"
                . "check your situation and if there's no problem,\n"
                . sprintf(q{remove "%s"}, $self->{_pid_file}) . "\n";
        }
    }
}

sub _read_pid_file {
    my $self = shift;
    my $pid = File::Slurp::read_file($self->{_pid_file});
    chomp $pid;
    return $pid;
}

sub _write_pid_file {
    my $self = shift;
    File::Slurp::write_file($self->{_pid_file}, $$, '');
    infof("<Server> wrote PID file '%s'", $self->{_pid_file});
}

sub _remove_pid_file {
    my $self = shift;
    unlink $self->{_pid_file} if -f $self->{_pid_file};
    infof("<Server> removed PID file '%s'", $self->{_pid_file});
}

sub _daemonize {
    my $self = shift;

    fork() && exit(0);

    (POSIX::setsid)
        || Carp::croak "Cannot detach from controlling process";

    $SIG{'HUP'} = 'IGNORE';
    fork() && exit(0);

    chdir '/';
    umask 0;

    close(STDIN);
    close(STDOUT);
    close(STDERR);

    open(STDIN,  "+>/dev/null");
    open(STDOUT, "+>&STDIN");
    open(STDERR, "+>&STDIN");
    open(NULL,   "/dev/null");
    <NULL> if (0);
}

1;
