use strict;
use warnings;

use Net::LDAP;

## Fill in the following as you would sitting down in a chair and logging in with standard Windows ActiveDirectory credentials..

$userName="turbine\\bgillespie";
$pw="08behemoth*";

## BTW, if you're getting these variables passed to you via a webpage, it's
#important to convert special characters that have been translated into their
#Unicode equivalents back to straight ASCII. (For example, if your password has
#a ! in it, it's going to get passed as "%21" (or whatever)).. So, to fix that,
#we repack the string with some sweet, sweet regex lovin'. If not, the following
#two lines should be omitted.

# $pw=~s/\%([A-Fa-f0-9]{2})/pack('C',hex($1))/seg;
# $pw=~s/\+/ /g;

## On with the show..

$host="k7e1b1.i.turbinegames.com";
$ldap=Net::LDAP->new($host) or die "Can't connect to LDAP server: $@";
$mesg=$ldap->bind($userName, password=>$pw);
$results=sprintf("%s",$mesg->error);
$mesg=$ldap->unbind;

if ($results=~/Success/)
{
   print "Thank you. You have successfully authenticated; You may now enter picturesofcatslookingatofficeequipment.com";
}
else
{
   print "You are a horrible, horrible person, and a slut. Try again.";
}
