package Tk::GraphMan;

require Tk;

use vars qw($VERSION);
$VERSION = '0.01';

use Tk::widgets (Canvas);
use base qw(Tk::Derived Tk::Canvas);

Construct Tk::Widget 'GraphMan';

use warnings;
use strict;

sub ClassInit {
	my($class, $mw) = @_;
	$class->SUPER::ClassInit($mw);
}

sub new{
	my ($class, $mw, %args) = @_;
	bless (\%args, $class);
	my $self = $mw->Canvas();
	$self->{'bgcolor'} = $args{-bgcolor} || 'black';
	$self->{'grid_color'} = $args{-grid_color} || '#008040';
	$self->{'height'} = $args{-height} || 100;
	$self->{'width'} = $args{-width} || 230;
	#$self->{'relief'} = $args{-relief} || 'sunken';
	$self->{'data_title'} = $args{-data_title} || 'Data';
	$self->{'data_color'} = $args{-data_color} || 'green';
	$self->{'text_color'} = $args{-text_color} || 'white';
	$self->{'showvalues'} = $args{-show_values} || 'off';
	$self->{'centerline_color'} = $args{-centerline_color} || '#ff0000';
	$self->{'centerline'} = $args{-centerline} ||'off';
	$self->{'interval'} = $args{-interval} || 1000;
	$self->{'position'} = 0;
	
	#initialize @grid_data array with half the width of the graph number of zeros
	for (my $i=1;$i<=($self->{'width'}/2);$i++){
		push (@{ $self->{'grid_data'} }, '0');
	}
	
	$self->configure(-width => $self->{'width'}, -height => $self->{'height'}, -relief => 'sunken', -background => $self->{'bgcolor'});
	&graph($self);
	return $self;
}

sub UNIVERSAL::start{
	#start scrolling the chart
	my ($self, %args) = @_;
	&graph($self); #start graphing immediately, otherwise graphing will start after $self->{'interval'}
	$self->{'timer'} = $self->repeat($self->{'interval'}, sub {
		&graph($self);
	});
}

sub UNIVERSAL::stop{
	#stop scrolling the chart
	my ($self, %args) = @_;
	$self->{'timer'}->cancel;
}

sub UNIVERSAL::data{
	my ($self, $data) = @_;
	shift @{ $self->{'grid_data'} };
	push (@{ $self->{'grid_data'} }, $data);
}

sub UNIVERSAL::data_array{
	my ($self, @data) = @_;
	shift @{ $self->{'grid_data'} }, scalar(@data);
	push (@{ $self->{'grid_data'} }, @data);
}

sub graph{
	my ($self, %args) = @_;
	$self->delete('grid');
	$self->delete('grid_data');
	$self->delete('grid_values');
	
	if ($self->{'centerline'} eq 'on'){
		$self->createLine( 0, $self->{'height'}/2, $self->{'width'}, $self->{'height'}/2, -tags => 'center_line', -fill => $self->{'centerline_color'}, -width => '1' );
	} else {
		$self->delete('center_line');
	}
	
	$self->{'position'} = 11 if $self->{'position'} < 1;
	
	my $i;
	for($i=11;$i<$self->{'width'};$i+=11){
		$self->createLine( 0, $i, $self->{'width'}, $i, -tags => 'grid', -fill => $self->{'grid_color'}, -width => '1' );
	}
  
	for($i=$self->{'position'};$i<$self->{'width'};$i+=11){
		$self->createLine( $i, 0, $i, $self->{'height'}, -tags => 'grid', -fill => $self->{'grid_color'}, -width => '1' );
	}
  
	if ($self->{'centerline'} eq 'on'){
		$self->createLine( 0, $self->{'height'}/2, $self->{'width'}, $self->{'height'}/2, -tags => 'center_line', -fill => $self->{'centerline_color'}, -width => '1' );
	} else {
		$self->delete('center_line');
	}
		
	my ($pos, $lastpoint);
	#graph grid data
	$pos = 1;
	$lastpoint = 0;
	foreach my $datapoint (@{ $self->{'grid_data'} }){
		$self->createLine( $pos, 100-$lastpoint, $pos+2, 100-$datapoint, -tags => 'grid_data', -fill => $self->{'data_color'}, -width => '1');
		if ($self->{'showvalues'} eq 'on'){
			$self->delete('grid_values');
			$self->createLine( 10, 6, 10, 15, -tags => 'grid_values', -fill => $self->{'data_color'}, -width => '3');
			$self->createText( 25, 10, -text => $self->{'data_title'}, -tags => 'grid_values', -fill => $self->{'text_color'});
			$self->createText( 50, 10, -text => $datapoint . '%', -tags => 'grid_values', -fill => $self->{'text_color'});
		}
		$pos+=2;
		$lastpoint = $datapoint;
	}
	$self->{'position'} -= 2;
	shift @{ $self->{'grid_data'} };
	&pad_grid_data($self);
}

sub pad_grid_data{
	my ($self, %args) = @_;
	while (scalar( @{ $self->{'grid_data'} } ) < ($self->{'width'}/2) ){
		push (@{ $self->{'grid_data'} }, '0');
	}
}

1;
__END__

=head1 NAME

TK::GraphMan - A scrolling Windows Task Manager style grid/graph chart

=head1 SYNOPSIS
	
	use Tk;
	use Tk::GraphMan;
	my $main = new MainWindow();
	my $grid1 = $main->GraphMan( -interval => 250 )->pack();
	$grid1->Tk::GraphMan::start();
	#do something to generate numeric data for graphing to the chart...
	$grid1->Tk::GraphMan::data(100); #add an integer to the graph's timeline, in scalar context
	# or ...	
	$grid1->Tk::GraphMan::data_array(35,36,37,38,39,40,38,36,33); #add an integer to the graph's timeline, in array context
	$main->MainLoop();
	
=head1 REQUIRES

Perl5.x, Tk, Exporter

=head1 DESCRIPTION

A scrolling Windows Task Manager style grid/graph chart.  This is a Tk::Canvas widget that has the look and feel of the Windows Task Manager grid/graph chart.

=head1 WIDGET-SPECIFIC OPTIONS

	-bgcolor
	Specify the background color of the chart.  (Default is 'black')
	
	-grid_color
	Specify the vertical and horizontal grid line colors of the chart.  (Default is '#008040')
	
	-data_color
	Color of the data being displayed plotted on the chart.  (Default is 'green')
	
	-interval(milliseconds)
	This options determines how frequently to scroll the chart.
	
	-height
	Sets the height of the chart, in pixels.  (Default is 100)	
	
	-width
	Sets the width of the chart, in pixels.  (Default is 230)
	
	-data_title
	Name of the data being displayed.  This is only used when the -showvalues option is set to 'on'.  (Default is 'Data')
	
	-text_color
	Sets the text color of the -data_title option.  This is only used when the -showvalues option is set to 'on'.  (Default is 'white')
	
	-showvalues('on'|'off')
	This option toggles printing of the current value (value on the far right of the chart) on and off.  (Default is 'off')
	
	-centerline('on'|'off')
	This option toggles a line to be drawn horizontally in the center of the graph.  (Default is 'off')
	
	-centerline_color
	Sets the color of the centerline.	 This is only used when the -centerline option is set to 'on'.  (Default is '#ff0000')

=head1 METHODS

=head2 start()

	Begin scrolling the chart.  The chart scrolls to the left, just like the Windows Task Manager chart.
	
=head2 stop()

	Stop scrolling the chart.

=head2 data($data)

	Plot a number stored in $data scalar on the chart.  Value will be added to the right-side of the chart.
	
=head2 data_array(@data)
	
	Plot a list of numbers stored in @data array on the chart.  Values will be added to the right-side of the chart.
	
=head1 AUTHOR

Brett Carroll, E<lt>brettwcarroll@hotmail.comE<gt>

=cut


































































