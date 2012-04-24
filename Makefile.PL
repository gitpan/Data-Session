use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
 ($] ge '5.005') ?
 (
  AUTHOR   => 'Ron Savage (ron@savage.net.au)',
  ABSTRACT => 'Persistent session data management',
 ) : (),
 clean =>
 {
	 FILES => 'blib/* Makefile MANIFEST Data-Session-*'
 },
 dist =>
 {
	 COMPRESS => 'gzip',
	 SUFFIX   => 'gz'
 },
 DISTNAME  => 'Data-Session',
 NAME      => 'Data::Session',
 PL_FILES  => {},
 PREREQ_PM =>
 {
	autovivification => 0.06,
	CGI              => 3.43,
	Class::Load      => 0.19,
	Data::Dumper     => 2.124,
	Data::UUID       => 1.217,
	DBD::SQLite      => 1.13,
	DBI              => 1.615,
	Digest::MD5      => 2.39,
	Digest::SHA      => 5.47,
	Fcntl            => 1.06,
	File::Basename   => 2.77,
	File::Path       => 2.07,
	File::Slurp      => 9999.13,
	File::Spec       => 3.30,
	File::Temp       => 0.22,
	FreezeThaw       => 0.5001,
	Hash::FieldHash  => 0.10,
	JSON             => 2.27,
	overload         => 1.07,
	parent           => 0.221,
	Safe             => 2.18,
	Scalar::Util     => 1.21,
	Storable         => 2.20,
	strict           => 1.04,
	Test::More       => 0.92,
	Test::Pod        => 1.44,
	Try::Tiny        => 0.07,
	vars             => 1.01,
	warnings         => 1.06,
	YAML::Tiny       => 1.44,
 },
 VERSION_FROM => 'lib/Data/Session.pm',
);
