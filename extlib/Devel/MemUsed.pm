package Devel::MemUsed;

=head1 NAME

Devel::MemUsed - returns how much memory as allocated since the Devel::MemUsed object construction

=head1 SYNOPSIS

    use Devel::MemUsed;
    
    my $memused = Devel::MemUsed->new();
    my %h = ( map { $_ => 1 } (1..100) );
    print "my hash allocated $memused bytes of memory\n";
    # for me 15632
    
    $memused->reset;
    
    my %h = ( map { $_ => 1 } (1..1000) );
    print "my hash allocated $memused bytes of memory\n";
    # for me 128104

=head1 DESCRIPTION

The purpose of this module is to see how much more memory is allocated after some
lines of code that were executed. How much memory a huge hash takes or an eval of
a "foreign" code.

Second purpose was to try L<Devel::Mallinfo> and L<Contextual::Return>. L<Devel::Mallinfo>
returns a hash filled with a C<mallinfo> struct. This struct is defined in F<malloc.h> and
looks like this:

    struct mallinfo {
      int arena;    /* non-mmapped space allocated from system */
      int ordblks;  /* number of free chunks */
      int smblks;   /* number of fastbin blocks */
      int hblks;    /* number of mmapped regions */
      int hblkhd;   /* space in mmapped regions */
      int usmblks;  /* maximum total allocated space */
      int fsmblks;  /* space available in freed fastbin blocks */
      int uordblks; /* total allocated space */
      int fordblks; /* total free space */
      int keepcost; /* top-most, releasable (via malloc_trim) space */
    };

While writing the tests I have discovered two strange thinks.

1st is that:

    my $x1 = "x" x (100*1024);           # this one takes >200kB of memory ?!?!?
    my $x2 = eval '"x" x (100*1024)';    # this one just   ~100kB

2nd is that C<"x" x 128*1024> is a magic border when C<hblkhd> start to increase. To get
some meaning full results of memory usage I had to add C<uordblks + hblkhd> together to
get total memory usage. What is the real meaning of C<hblkhd> and how it works with
memory allocation of huge strings is unclear to me. If you know some details or
explanation I'll be more then happy to hear it.

On YAPC Europe 2008 Darko Obradovic showed a code snipped using L<Devel::Mallinfo>
and a function C<mallinfo> to get the statistics of memory allocated using C<malloc>.
On this same conference Damian Conway in his keynote was showing L<Contextual::Return>.
I put those two together and play around, hopefully producing something useful. :-)

=cut

use warnings;
use strict;

our $VERSION = '0.01';

use base 'Class::Accessor::Fast';
use Contextual::Return;
use Devel::Mallinfo 'mallinfo';

=head1 PROPERTIES

=cut

__PACKAGE__->mk_accessors(qw{
    memory_offset
});

=head1 METHODS

=head2 new()

Object constructor.

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new({ @_ });
    
    $self->reset;
    
    return ACTIVE
        OBJREF   { $self }
        DEFAULT  { $self->used }
    ;
}


=head2 used()

Returns how many bytes of memory is used.

=cut

sub used {
    my $self = shift;    
    return $self->allocated_memory - $self->memory_offset;
}


=head2 reset()

Reset the "counter" and start to count the memory allocated from the line of code
where the C<reset()> was called.

=cut

sub reset {
    my $self = shift;
    return $self->memory_offset($self->allocated_memory);
}


=head2 allocated_memory()

Return total number of C<mmap> allocated memory since the start of the program.

=cut

sub allocated_memory {
    my $self = shift;
    
    my $m = mallinfo();
    return $m->{'uordblks'} + $m->{'hblkhd'};
}

'always a lot, what do you think?';


__END__

=head1 THANKS TO

Darko Obradovic for his talk about L<http://www.cosair.com>.

and

Damian Conway for his YAPC Europe 2008 keynote + the hack number #92 in
"Perl Hacks" book where I first read about L<Contextual::Return>.

=head1 AUTHOR

Jozef Kutej

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
