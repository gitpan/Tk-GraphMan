use ExtUtils::MakeMaker;
WriteMakefile
  (
   'NAME'	=> 'Tk::GraphMan',
   'VERSION_FROM' => 'GraphMan.pm',
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
   PM            => 
   {
    'TreeGraph.pm'   => '$(INST_LIB)/Tk/GraphMan.pm',
   },
   PREREQ_PM   => 
   {
    'Tk'	=> '0', 
   },
    	AUTHOR => 'Brett Carroll (brettwcarroll@hotmail.com)',
      ABSTRACT => 'Create a Windows Task Manager style scrolling Graph/Chart',
  );
