# Perlish way to generate snoof
# If you're looking for the reason this atrocity became a perl module,
# blame the crackheads on OPN #slashdot

package Silly::Werder;

# Copyright 2000 Dave Olszewski.  All rights reserved.
# It may be used and modified freely, but I do request that this copyright
# notice remain attached to the file.  You may modify this module as you
# wish, but if you redistribute a modified version, please attach a note
# listing the modifications you have made.

$Silly::Werder::VERSION='0.03';

use strict;
use Exporter;

use constant SENTENCE     => ".";
use constant QUESTION     => "?";
use constant EXCLAIMATION => "!";

use vars qw($VERSION $PACKAGE
            @ISA
            @EXPORT_OK);

my @werder_functions = qw(line sentence question exclaimation
                          set_werds_num set_syllables_num
                          set_cons_weight);

@EXPORT_OK = (@werder_functions);

my $self;

sub new {
  my $self = {};
  bless $self;

  # Initialize the internal variables
  $self->_init($self);

  return $self;
}

sub DESTROY { }

##########################################################################
#  Sets the min and max number of werds that will go into the sentence
##########################################################################
sub set_werds_num($$) {

  my $obj;
  if(scalar(@_) == 3) {
    $obj = shift;
  }

  my ($min, $max) = @_;
  my $target;
  if($min > $max) { return; }

  if(ref $obj) {
    $target = $obj;
  }
  else {
    $target = $self;
  }

  $target->{"min_werds"} = $min;
  $target->{"max_werds"} = $max;

  return;

}


##########################################################################
#  Sets the min and max number of syllables that can go into a werd
##########################################################################
sub set_syllables_num($$) {

  my $obj;
  if(scalar(@_) == 3) {
    $obj = shift;
  }

  my ($min, $max) = @_;
  my $target;
  if($min > $max) { return; }

  if(ref $obj) {
    $target = $obj;
  }
  else {
    $target = $self;
  }

  $target->{"min_syllables"} = $min;
  $target->{"max_syllables"} = $max;

  return;

}


##########################################################################
#  Set the percentage of the time a werd will start with a consonant 
##########################################################################
sub set_cons_weight($) {

  my $obj;
  if(scalar(@_) == 2) {
    $obj = shift;
  }

  my $weight = shift;
  my $target;

  # Do a little trick in case they passed something stupid
  $weight += 0;

  if($weight > 100) { $weight = 100; }
  if($weight < 0) { $weight = 0; }

  if(ref $obj) {
    $target = $obj;
  }
  else {
    $target = $self;
  }

  $target->{"cons_weight"} = $weight;

  return;

}

##########################################################################
#  Create a random type of sentence
##########################################################################
sub line {
  my $obj=shift;
  my ($line, $target);
  my $which_kind = int(rand() * 3);

  
  if(ref $obj) {
    $target = $obj;
  }
  else {
    $target = $self;
  }

  if($which_kind == 0) { $line = _make_line($target, SENTENCE); }
  if($which_kind == 1) { $line = _make_line($target, QUESTION); }
  if($which_kind == 2) { $line = _make_line($target, EXCLAIMATION); }

  return $line;
}

##########################################################################
#  Create a sentence with a period
##########################################################################
sub sentence {

  my $obj=shift;
  my $target;

  if(ref $obj) {
    $target = $obj;
  }
  else {
    $target = $self;
  }

  my $line = _make_line($target, SENTENCE);
  return $line;
}

##########################################################################
#  Create a question
##########################################################################
sub question {

  my $obj=shift;
  my $target;

  if(ref $obj) {
    $target = $obj;
  }
  else {
    $target = $self;
  }

  my $line = _make_line($target, QUESTION);
  return $line;
}

##########################################################################
#  Create an exclaimation
##########################################################################
sub exclaimation {

  my $obj=shift;
  my $target;

  if(ref $obj) {
    $target = $obj;
  }
  else {
    $target = $self;
  }

  my $line = _make_line($target, EXCLAIMATION);
  return $line;
}

sub _init {

  my $obj = shift;

  if(ref $obj) {
    $obj->{"min_werds"} = 5;
    $obj->{"max_werds"} = 9;

    $obj->{"min_syllables"} = 3;
    $obj->{"max_syllables"} = 7;

    # This one is the percentage of the time werds will start with a consonant
    $obj->{"cons_weight"} = 75;
  }
  else {
    $self->{"min_werds"} = 5;
    $self->{"max_werds"} = 9;

    $self->{"min_syllables"} = 3;
    $self->{"max_syllables"} = 7;

    # This one is the percentage of the time werds will start with a consonant
    $self->{"cons_weight"} = 75;
  }
}

# Call the init function at the time we load the module to initialize the vars
# for class methods
_init();

sub _make_line($$) {
  my ($obj, $ending) = @_;
  my ($line, $num_werds, $werd_counter);

  my @vowels = qw/a e i o u ee ai ie io oo ea oi oa ou a e i o u/;
  my @beginning_consonants = qw/sn sl tr l bl fl cr b dr wr 
                                gr pl squ qu cl spl fr m k/;

  my @ending_consonants = qw/nd ck ll mn w ls sk rt rd zz gh ght ny 
                             nct ch st nt m ng ly d ff t/;

  my @misc_consonants = qw/sn d sp s th r t p sh ph ct nk str f h c 
                            m n cr x st b g k l v w z/;

  $num_werds = int(rand() * ($obj->{"max_werds"} - $obj->{"min_werds"} + 1) + $obj->{"min_werds"});
  for($werd_counter = 0; $werd_counter < $num_werds; $werd_counter++) {

    my $werd;
    my $counter = 0;
    my $num_syllables = int(rand() * ($obj->{"max_syllables"} - $obj->{"min_syllables"} + 1) + $obj->{"min_syllables"});

    # Decide whether to start this werd with a consonant of vowel
    my $flip;
    if(rand() * 100 < $obj->{"cons_weight"}) { $flip = 1; }

    while($counter < $num_syllables) {

      if(($flip and (!($counter % 2))) or (!$flip and ($counter % 2))) {

        if($counter == 0) {
          # Pick from the beginning consonants
          $werd .= $beginning_consonants[int(rand() * scalar(@beginning_consonants))];
        }
        elsif($counter == $num_syllables-1) {
          # Pick from the ending consonants
          $werd .= $ending_consonants[int(rand() * scalar(@ending_consonants))];
        }
        else {
          # Pick from the misc consonants
          $werd .= $misc_consonants[int(rand() * scalar(@misc_consonants))];
        }
      }
      else {
        # I'd like to buy a vowel
        $werd .= $vowels[int(rand() * scalar(@vowels))];
      }

      $counter++;
    }

    $line .= " $werd";
  }

  $line =~ s/^.(.)/uc($1)/e;
  $line .= $ending;
  $line .= "\n";
  return $line;
}

1;

__END__

=head1 NAME

Werder - Meaningless gibberish generator

=head1 SYNOPSIS

  use Silly::Werder;

  my $foo = new Silly::Werder;

  # Set the min and max number of werds per line
  $foo->set_werds_num(5, 9);      

  # Set the min and max # of syllables per werd
  $foo->set_syllables_num(3, 7);

  # Set the percentage of the time a werd will start with a consonant
  $foo->set_cons_weight(75);
 
  # Return a random sentence, question, or exclaimation
  $line = $foo->line;

  $sentence = $foo->sentence;
  $question = $foo->question;
  $question = $foo->exclaimation;

  # Generate a long random sentence calling as a class method
  Silly::Werder->set_werds_num(10,20);
  print Silly::Werder->line;

  # All of the above methods can be used as either class methods
  # or object methods.

=head1 DESCRIPTION

This module is used to create pronouncable yet completely meaningless language.  It is good for sending to a text-to-speech program (ala festival), generating passwords, annoying people on irc, and all kinds of fun things.

=head1 BUGS

The only bug I am aware of is the (intentional) spelling of 'werd' throughout the souce and documentation =)

=head1 AUTHOR

Werder was created and implemented by Dave Olszewski, aka cxreg.  You can send comments, suggestions, flames, or love letters to dave.olszewski@osdn.com

=cut
