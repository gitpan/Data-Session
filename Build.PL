use Module::Build;

Module::Build -> new
(
 module_name    => 'Data::Session',
 license        => 'artistic_2',
 dist_abstract  => 'Persistent session data management',
 dist_author    => 'Ron Savage <ron@savage.net.au>',
 build_requires =>
 {
	 Config::Tiny             => 2.14,
	 DBIx::Admin::CreateTable => 2.07,
	 Test::More             => 0.92,
#	 Test::Pod                => 1.45, # Make it optional. See t/pod.t
 },
 configure_requires =>
 {
	 Module::Build => 0.38,
 },
 requires =>
 {
	autovivification         => 0.06,
	CGI                      => 3.43,
	Class::Load              => 0.19,
	Config::Tiny             => 2.14,
	Data::Dumper             => 2.124,
	Data::UUID               => 1.217,
	DBD::SQLite              => 1.39,
	DBI                      => 1.615,
	DBIx::Admin::CreateTable => 2.07,
	Digest::MD5              => 2.39,
	Digest::SHA              => 5.47,
	Fcntl                    => 1.06,
	File::Basename           => 2.77,
	File::Path               => 2.07,
	File::Slurp              => 9999.13,
	File::Spec               => 3.30,
	File::Temp               => 0.22,
	FreezeThaw               => 0.5001,
	Hash::FieldHash          => 0.10,
	JSON                     => 2.27,
	overload                 => 1.07,
	parent                   => 0.221,
	Safe                     => 2.18,
	Scalar::Util             => 1.21,
	Storable                 => 2.20,
	strict                   => 1.04,
	Try::Tiny                => 0.07,
	vars                     => 1.01,
	warnings                 => 1.06,
	YAML::Tiny               => 1.44,
 },
) -> create_build_script();
