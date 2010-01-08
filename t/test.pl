# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/test.pl'

######################### We start with some black magic to print on failure.


BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::GraphMan;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

#Test 2:
use Tk;
my $main = new MainWindow();
my $grid1 = $main->GraphMan( -interval => 250 )->pack();
my $result = ref($grid1);
print ($result eq "Tk::Canvas" ? "ok 2\n" : "not ok 2\n");


