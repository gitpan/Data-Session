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
	LICENSE   => 'artistic_2',
 PL_FILES  => {},
 PREREQ_PM =>
 {
	autovivification         => 0,
	CGI                      => 3.63,
	Class::Load              => 0.19,
	Config::Tiny             => 2.14,
	Data::Dumper             => 2.145,
	Data::UUID               => 1.218,
	DBD::SQLite              => 1.39,
	DBI                      => 1.627,
	DBIx::Admin::CreateTable => 2.07,
	Digest::MD5              => 2.52,
	Digest::SHA              => 5.84,
	Fcntl                    => 1.06,
	File::Basename           => 2.77,
	File::Path               => 2.07,
	File::Slurp              => 9999.19,
	File::Spec               => 3.30,
	File::Temp               => 0.22,
	FreezeThaw               => 0.5001,
	Hash::FieldHash          => 0.14,
	JSON                     => 2.59,
	overload                 => 0,
	parent                   => 0,
	Safe                     => 2.35,
	Scalar::Util             => 1.27,
	Storable                 => 2.39,
	strict                   => 0,
	Test::More               => 0.92,
#	Test::Pod                => 1.45, # Make it optional. See t/pod.t
	Try::Tiny                => 0.12,
	vars                     => 0,
	warnings                 => 0,
	YAML::Tiny               => 1.51,
 },
 VERSION_FROM => 'lib/Data/Session.pm',
);
