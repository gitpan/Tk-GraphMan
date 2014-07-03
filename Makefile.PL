use ExtUtils::MakeMaker;
WriteMakefile
  (
   'NAME' => 'Tk::GraphMan',
   'VERSION_FROM' => 'GraphMan.pm',
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
   PM            =>
   {
    'GraphMan.pm'   => '$(INST_LIB)/Tk/GraphMan.pm',
   },
   PREREQ_PM   =>
   {
    'Tk'  => '0',
   },
      AUTHOR => 'Brett Carroll (bcarroll@cpan.org)',
      ABSTRACT => 'Create a Windows Task Manager style scrolling Graph/Chart',
  );
