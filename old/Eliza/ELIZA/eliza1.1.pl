#!/usr/bin/perl
# liz.pl by Andrew Daviel <andrew@Vancouver-Webpages.com> (http://vancouver-webpages.com)
# based on "ELIZA.BAS" by Creative Computing, found during an archaelogical dig
# on my DOS hard drive
#
# Bug fixes Feb96 by Yaron Keren
#
$alarms = 0 ; # set to 1 to enable prompting
 &init ;
print "My name is Eliza.  I'm a Computer.\n";
print "I have been programmed to assist humans with their\n";
print "problems.  \n";
print "What is your name? ";
$name = <STDIN> ; chop ($name) ;
print "So, $name, what is the problem? " ;
 
L110:
# *** User input ***
while (<STDIN>) {
if ($alarms) {  alarm(0) ;}
  $tmo = 0 ;
  tr/A-Z/a-z/ ;
  tr/a-z //cd ;
  $i = " ".$_." " ;
 
  # *** Find keyword in I$ ***
  $s = 0;
  for ($k=1 ; $k <= $#key ; $k++) {
    if ($s > 0) { last ; }
    $ky = " ".$key[$k]." " ;
    $l = index($i, $ky) + 1 ;
    if ($l > 0) { $s = $k ; $t = $l ; $f = $key[$k] ; }
  }
  if ($s > 0) {
    $k = $s ; $l = $t
  } else {
    $k = $#key ; goto L490 ;
  }
  $_ = " ".substr($i,$l+length($f)+1)." ";
  chop ;
  # *** Perform string swaps for persons ***
  s/ are / AM / ; s/ am / are / ; s/ were / WAS / ; s/ was / were / ;
  s/ you / I / ; s/ i / you / ; s/ your / MY / ; s/ my / your / ;
  s/ ive / YOUVE / ; s/ youve / ive / ; s/ im / YOURE / ; s/ youre / im /;
  s/ me / YOU / ;
  tr/A-Z/a-z/ ;
  $c = $_ ;
L490:
 
  # *** Use keyword number K to select reply ***
  $rk = $r[$k] ;
  $f = $reply[$rk] ;
  # $r[$k]++ ; if ($r[$k] > $n[$k]) { $r[$k] = $s[$k] ; }
  $r[$k]++ ;
  if ($k == $#key) {
    if ($r[$k] > $#reply) { $r[$k] = $s[$k] ; }
  } else {
    $k2=$k+1;
    while ($s[$k]==$s[$k2]) { $k2++; }
    if ($r[$k] >= $s[$k2]) { $r[$k] = $s[$k] ; }
  }
 
  $_ = $f ; chop ; s/\*/$name/ ;
  $last = substr($f,-1,1) ;
  if ($last eq "/") {
     print "$_\n";
  } else {
    print "$_$c$last\n";
  }
  if ($alarms) {  alarm($timeout) ; }
}
 
sub init {
$SIG{'ALRM'} = "timed_out" ;
$| = 1 ; # flush buffers
  @reply = (0,
# can you                               1
    "Don't you believe that I can?",
    "Perhaps you would like to be able to.",
    "You want me to be able to?",
# can i                                 4
    "Perhaps you don't want to?",
    "Do you want to be able to?",
# you are, youre                        6
    "What makes you think I am?",
    "Does it make you happy to think I am?",
    "Perhaps you would like to be.",
    "Do you sometimes wish you were?",
# i dont                                10
    "So you don't?",
    "Why don't you?",
    "So you'd like to!",
    "Does this bother you?/",
# i feel                                14
    "I'd like to know more!",
    "Do you often feel?",
    "Do you enjoy feeling?",
# why dont you                          17
    "Do you really believe I dont?",
    "Perhaps, in my own time, I will.",
    "Do you want me to?",
# why cant i                            20
    "Do you think I should be able to?",
    "Why can't you?",
# are you                               22
    "Why are you interrested in whether or not I am?",
    "Would you prefer I were not?",
    "PERHAPS IN YOUR FANTASIES I AM*",
# i cant                                25
    "How do you know you can't?",
    "Have you tried?/",
    "Perhaps you can, now,!",
# i am, im                              28
    "So you came to me because you are.",
    "How long have you been?",
    "Do you think it is normal to be?",
    "Do you enjoy being?",
# you                                   32
    "Let's get back to your problem./",
    "Oh, I?",
    "Well, let's talk about you for a while now./",
# i want                                35
    "What would it mean to you if you got?",
    "Why do you want?",
    "Suppose you soon got.",
    "What if you never got?",
    "Sometimes I also want.",
# what, how, who, where, when, why      40
    "Why do you ask?/",
    "Does that question interrest you?/",
    "What answer would please you most?/",
    "What do you think?/",
    "Are such questions on your mind often?/",
    "What do you really want to know?/",
    "Have you asked anyone else?/",
    "Have you asked these questions before?/",
    "What exactly are you thinking about?/",
# name                                  49
    "Well, lets be nice, now./",
    "Let's not talk about people behind their back./",
# cause,because                         51
    "Is that the real reason?/",
    "Any other reasons?/",
    "Does that reason explain anything else?/",
    "What other reasons might there be?/",
#sorry                                  55
    "Oh, excuse me!/",
    "No hard feelings, now./",
    "Why do you feel sorry?/",
    "Listen, I'm on your side./",
# dream                                 59
    "What does the dream suggest to you?/",
    "Do you dream often?/",
    "It must be nice to have dreams.  I don't.../",
    "The dream comes from deep in your mind./",
#hello, hi                              63
    "Well, how do you do!  Can I help you?/",
#maybe                                  64
    "You seem somewhat uncertain./",
    "Why the uncertain tone?/",
    "Can you be more positive?/",
    "You aren't sure?/",
    "You don't know?/",
# no                                    69
    "Oh.  Well, then, what?",
    "You seem a little negative./",
    "Why not?/",
    "Are you sure?/",
    "Why 'No'?/",
# your                                  74
    "Why are you worried about my?",
    "What about your own?",
# always                                76
    "Can you think of a specific example?/",
    "When?/",
    "What are you thinking of?/",
    "Oh, nothing is Always the same./",
# think                                 80
    "Think so?/",
    "But you aren't sure you.",
    "Do you doubt ?",
# alike                                 83
    "In what way?/",
    "What resemblance do you see?/",
    "What does the similarity suggest to you?/",
    "What other connections do you see?/",
    "Could there really be some connection?/",
    "How?/",
    "You seem rather sure of this!/",
# yes                                   90
    "Are you sure?/",
    "I see./",
    "Aha!/",
# friend                                93
    "What about your friends?/",
    "Do your friends worry you?/",
    "I think they probably mean well./",
    "Perhaps you should be more open with your friends./",
    "Do you like your friends?/",
    "Well, everyone needs friends./",
# computer, eliza
    "Remember, I am a computer./",
    "Meaning me, perhaps?/",
    "Think of me as a frend./",
    "What about computers?/",
    "So machines are part of the problem?/",
    "I like to think computers can help people./",
    "Sometimes computers do cause people problems./",
# mother
    "I'm sure your mother loved you.",
    "Were you breast fed?",
# father
    "Would you like to be like your father?",
    "I'm sure your father loved you.",
    "Do you feel threatened by your father?",
# no key found
    "So what does this suggest to you?/",
    "Go on,*.",
    "I see./",
    "I'm not sure I understand you fully./",
    "Uhhhuh/",
    "Could you be more specific?/",
    "Interesting!/",
    "Do you have any friends?/",
    "Go on./",
    "So what seems to be the problem?/",
    "Now tell me, * , do you have any dreams?/",
    "Can you elaborate on that?/",
    "Tell me about your mother./",
    "Tell me about your father./",
    "Uhhhuh/",
    "Tell me about your childhood./",
    "That's interesting!/"
    ) ;
  @key = (0,
    "can you","can i","you are","youre","i dont","i feel",
    "why dont you","why cant i","are you","i cant","i am","im",
    "you","i want","what","how","who","where","when","why",
    "name","cause","because","sorry","dream","hello","hi","maybe",
    "no","your","always","think","alike","same","yes","ok","friend","friends",
    "computer","eliza","mother","father","nokeyfound") ;
 
  @s = ( 0,
    1,4,6,6,10,14,
    17,20,22,25, 28,28,
    32,35,40,40,40,40,40,40,
    49,51,51,55,59,63,63,64,
    69,74,76, 80,83,83,90,90,93,93,
    99,99,106,108,111 ) ;
 
  @prompt = (0,
  "Go on!",
  "You seem rather silent.",
  "Tell me, *, do you have any dreams?",
  "Tell me more!" ) ;
 
  @prompt2 = (0,
  "*?",
  "Are you still there?",
  "Are you asleep?",
  "When I snap my fingers you will wake up!",
  "Are you still asleep?",
  "Hello?" ) ;
 
  unless ($#s == $#key) { die "start-key mismatch\n"; }
  for ($x=1 ; $x <= $#key ; $x++ ) {
    $r[$x] = $s[$x] ;
  }
  $timeout = 19 ;
  $pn = 0 ; $pn2 = 0 ; $tmo = 0 ;
}
sub timed_out {
  $tmo++ ;
  if ($tmo > 2 ) {
    $pn2++ ; if ($pn2 > $#prompt2) { $pn2 = 1 ; }
    $prompt = $prompt2[$pn2] ;
  } else {
    $pn++ ; if ($pn > $#prompt) { $pn = 1 ; }
    $prompt = $prompt[$pn] ;
  }
  $prompt =~ s/\*/$name/ ;
  print "$prompt\n ";
  $SIG{'ALRM'} = "timed_out" ;
#  alarm($timeout) ;
}
 
