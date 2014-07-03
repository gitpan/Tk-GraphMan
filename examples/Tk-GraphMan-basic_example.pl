#!/usr/bin/perl
use warnings;
use strict;
use Tk;
use Tk::GraphMan;

my $main = new MainWindow();
my $grid1 = $main->GraphMan( -interval => 250 )->pack();
$grid1->Tk::GraphMan::start();

#create a timer to update the graph with data
$main->repeat( 250, sub{ $grid1->Tk::GraphMan::data( &get_metric ); } );

$main->MainLoop();

sub get_metric {
  my $metric =  rand(100);  #collect a single integer value
  return($metric);          #return the collect value/metric
}