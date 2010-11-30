use Module::Build;

Module::Build -> new
(
	module_name    => 'Data::Session',
	license        => 'artistic',
	dist_abstract  => 'Persistent session data management',
	dist_author    => 'Ron Savage <ron@savage.net.au>',
	build_requires =>
	{
		Test::More => 0.96,
		Test::Pod  => 1.44,
	},
	requires =>
	{
		autovivification         => 0.06,
		CGI                      => 3.50,
		common::sense            => 3.3,
		Data::Dumper             => 2.128,
		Data::UUID               => 1.217,
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
	},
) -> create_build_script();
