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
	 autovivification         => 0.06,
	 CGI                      => 3.50,
	 Data::Dumper             => 2.128,
	 Data::UUID               => 1.217,
	 DBD::SQLite              => 1.13,
	 DBI                      => 1.615,
	 Digest::MD5              => 2.51,
	 Digest::SHA              => 5.48,
	 DBIx::Admin::CreateTable => 2.07,
	 DBIx::Admin::DSNManager  => 1.00,
	 Fcntl                    => 1.06,
	 File::Path               => 2.08,
	 File::Slurp              => 9999.13,
	 File::Spec               => 3.33,
	 File::Temp               => 0.22,
	 FreezeThaw               => 0.5001,
	 Hash::FieldHash          => 0.10,
	 JSON                     => 2.27,
	 Module::Load             => 0.18,
	 parent                   => 0.224,
	 Safe                     => 2.29,
	 Scalar::Util             => 1.23,
	 Storable                 => 2.24,
	 Try::Tiny                => 0.07,
	 vars                     => 1.01,
	 YAML::Tiny               => 1.44,
	 Test::More               => 0.96,
	 Test::Pod                => 1.44,
 },
 VERSION_FROM => 'lib/Data/Session.pm',
);
