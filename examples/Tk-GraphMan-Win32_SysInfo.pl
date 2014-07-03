use warnings;
use strict;
use Tk;
use Tk::Menu;
use Win32::SystemInfo::CpuUsage;
use Win32::SystemInfo;

my $X = "233";
my $Y = "103";
my $winX = 10;
my $winY = 20;
my $dragFromX = 0;
my $dragFromY = 0;
my $isDragging = 0;

my $stayontop = 0;
my $showvalues = 0;
my $linecolor = 'green';

my $main = MainWindow->new();
$main->overrideredirect(1);
my $timeline = $main->Canvas( -background => 'black', -height => 100,-width => 230, -relief => 'sunken' )->pack();

my $menu = $main->Menu(-tearoff => 0);
my $CPU = 1;
my $RAM = 1;
my $monitor = $menu->cascade(-label => 'Monitor', -tearoff => 0, -menuitems => [
  [Checkbutton => 'CPU', -variable => \$CPU],
  [Checkbutton => 'RAM', -variable => \$RAM],
  ]);
$menu->Checkbutton( -label => 'Show ~Values', -variable => \$showvalues),
$menu->Checkbutton( -label => 'Stay on ~Top', -variable => \$stayontop, -command => sub{ stayontop(); }),
$menu->Separator();
$menu->Button(-label => '~Exit', -command => sub{ $main->destroy(); });

my $position = 11;
my (@cpudata, @ramdata);

&initialize();

my $prevObject = "";
my ($cpu, %mHash, $ram);
my $delay = 1000;
my $timer = $main->repeat($delay, sub {
  if ($CPU){
    $cpu = Win32::SystemInfo::CpuUsage::getCpuUsage(100);
    shift @cpudata;
    push(@cpudata, $cpu);
  }
  if ($RAM){
    Win32::SystemInfo::MemoryStatus(%mHash);
    $ram = $mHash{MemLoad};
    shift @ramdata;
    push(@ramdata, $ram);
  }
  &graph($timeline);
});

$main->bind('<3>', sub { my ($x, $y) = $main->pointerxy; &showmenu($x,$y) } );
$main->bind ('<ButtonPress-1>', \&buttonPress);
$main->bind ('<ButtonRelease-1>', \&buttonRelease);
$main->bind ('<Motion>', \&motion);

$main->update;

MainLoop;

sub graph{
  my $timeline = shift;
  $timeline->delete('grid');
  $timeline->delete('cpudata');
  $timeline->delete('ramdata');
  $timeline->delete('cpuvalues');
  $timeline->delete('ramvalues');

  $position = 11 if $position < 1;

  my $i;
  for($i=11;$i<230;$i+=11){
    $timeline->createLine( 0, $i, 230, $i, -tags => 'grid', -fill => '#008040', -width => '1' );
  }

  for($i=$position;$i<230;$i+=11){
    $timeline->createLine( $i, 0, $i, 100, -tags => 'grid', -fill => '#008040', -width => '1' );
  }

  my ($pos, $lastpoint);
  if ($CPU){
    #graph cpu data
    $pos = 1;
    $lastpoint = 0;
    foreach my $datapoint (@cpudata){
      $timeline->createLine( $pos, 100-$lastpoint, $pos+2, 100-$datapoint, -tags => 'cpudata', -fill => 'green', -width => '1');
      if ($showvalues){
        $timeline->delete('cpuvalues');
        $timeline->createLine( 10, 6, 10, 15, -tags => 'cpuvalues', -fill => 'green', -width => '3');
        $timeline->createText( 25, 10, -text => 'CPU', -tags => 'cpuvalues', -fill => 'white');
        $timeline->createText( 50, 10, -text => $datapoint . '%', -tags => 'cpuvalues', -fill => 'white');
      }
      $pos+=2;
      $lastpoint = $datapoint;
    }
  }

    if ($RAM){
    #graph ram data
    $pos = 1;
    $lastpoint = 0;
    foreach my $datapoint (@ramdata){
      $timeline->createLine( $pos, 100-$lastpoint, $pos+2, 100-$datapoint, -tags => 'ramdata', -fill => 'yellow', -width => '1');
      if ($showvalues){
        $timeline->delete('ramvalues');
        $timeline->createLine( 10, 16, 10, 25, -tags => 'ramvalues', -fill => 'yellow', -width => '3');
        $timeline->createText( 25, 20, -text => 'RAM', -tags => 'ramvalues', -fill => 'white');
        $timeline->createText( 50, 20, -text => $datapoint . '%', -tags => 'ramvalues', -fill => 'white');
      }
      $pos+=2;
      $lastpoint = $datapoint;
    }
  }
  $position -= 2;
}

sub showmenu {
  my ($x, $y) = @_;
  $menu->post($x, $y);  # Show the popup menu
}

sub buttonPress {
  $isDragging = 1;
  $dragFromX = $Tk::event->X - $winX;
  $dragFromY = $Tk::event->Y - $winY;
}

sub buttonRelease {
  $isDragging = 0;
}

sub motion {
  return unless $isDragging;
  my $curX = $Tk::event->X;
  my $curY = $Tk::event->Y;
  $curX -= $dragFromX;
  $curY -= $dragFromY;
  $winX = $curX;
  $winY = $curY;
  $main->geometry($X . "x$Y+$curX+$curY");
}

sub initialize{
  #initialize @cpudata and @ramdata arrays with 115 zeros (half the width of the graph)
  for (my $i=1;$i<=115;$i++){
    push (@cpudata, '0');
  }

  for (my $i=1;$i<=115;$i++){
    push (@ramdata, '0');
  }

  &graph($timeline);
}

sub stayontop{
  $main->attributes(-topmost => $stayontop);
}