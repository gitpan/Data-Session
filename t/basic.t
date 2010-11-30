#!/usr/bin/perl

no autovivification;

use common::sense;

use warnings 'uninitialized';

use lib 't';

use BerkeleyDB;

use Cache::Memcached;

use DBI;

use File::Temp;

use Test;

use DBIx::Admin::DSNManager;

use Test::More;

use Try::Tiny;

# -----------------------------------------------

sub BEGIN { use_ok('Data::Session'); }

# -----------------------------------------------

sub prepare_berkeleydb
{
	my($self, $config) = @_;
	my($env) = BerkeleyDB::Env -> new
	(
		Home  => File::Spec -> tmpdir,
		Flags => DB_CREATE | DB_INIT_CDB | DB_INIT_MPOOL,
	);

	my($cache);

	if ($env)
	{
		$cache = BerkeleyDB::Hash -> new
		(
			Env      => $env,
			Filename => 'data.session.id.bdb',
			Flags    => DB_CREATE,
		);
	}

	if (! $cache)
	{
		report("Skipping test. BerkeleyDB error: $BerkeleyDB::Error");
	}

	return $cache;

} # End of prepare_berkeleydb.

# -----------------------------------------------

sub prepare_memcached
{
	my($self, $config) = @_;

	# Do a simple check to see if memcached is running.

	my($cache) = Cache::Memcached -> new({namespace => 'data.session.id', servers => ['127.0.0.1:11211']});
	my($test)  = $cache -> set(time => time);

	if ($test && ($test == 1) )
	{
		# It's running, so clean up the test.

		$cache -> delete(time);
	}
	else
	{
		$cache = undef;

		report('Skipping test because memcached is not responding');
	}

	return $cache;

} # End of prepare_memcached.

# -----------------------------------------------

sub report
{
	my($s) = @_;

	print STDERR "# $s\n";

} # End of report.

# -----------------------------------------------

sub run
{
	my($config, $id, $serializer, $test_count) = @_;

	my($cache);
	my(@dsn, $directory, $type);
	my($tester);

	try
	{
		# WTF: You cannot use DBI -> parse_dsn(...) || die $msg;
		# even though that's what the docs say to do.
		# BAIL_OUT reports (e.g.): ... Error in type: Unexpected component 'sha1' ...

		@dsn = DBI -> parse_dsn($$config{dsn});

		if ($#dsn < 0)
		{
			die __PACKAGE__ . ". Can't parse dsn '$$config{dsn}'";
		}

		if ($$config{dsn} =~ /dbi:BerkeleyDB/)
		{
			$cache = prepare_berkeleydb($config);

			if (! $cache)
			{
				return;
			}
		}
		elsif ($$config{dsn} =~ /dbi:Memcached/)
		{
			$cache = prepare_memcached($config);

			if (! $cache)
			{
				return;
			}
		}

		# The EXLOCK option is for BSD-based systems.

		$directory = File::Temp::newdir('temp.XXXX', CLEANUP => 1, EXLOCK => 0, TMPDIR => 1);
		$type      = "driver:$dsn[1];id:$id;serialize:$serializer";
		$tester    = Test -> new
		(
			cache     => $cache,
			directory => $directory,
			dsn       => $$config{dsn},
			dsn_attr  => $$config{attributes},
			id        => $id eq 'Static' ? 1234 : 0,
			id_base   => 1000, # For id:AutoIncrement.
			id_step   => 2,
			password  => $$config{password},
			type      => $type,
			username  => $$config{username},
			verbose   => 1,
		);

		subtest $type => sub
		{
			$$test_count += $tester -> run;
		};

		# At the end of run(), all sessions get deleted.
		# Hence we don't need to clean up the cache.

		#if ($$config{dsn} =~ /dbi:Memcached/)
		#{
		#	$cache -> flush_all;
		#}

		return $tester;
	}
	catch
	{
		# This extra call to done_testing just stops an extra error message.

		done_testing($$test_count);
		BAIL_OUT($_);
	}

} # End of run.

# -----------------------------------------------

my($ini_file)   = shift || 't/basic.ini';
my($dsn_config) = DBIx::Admin::DSNManager -> new(file_name => $ini_file) -> config;
my($test_count) = 1; # The use_ok in BEGIN counts as the first test.

my($config);
my($tester);

for my $dsn_name (sort keys %$dsn_config)
{
	$config = $$dsn_config{$dsn_name};

	next if ( ($$config{active} == 0) || ($$config{use_for_testing} == 0) );

	# We skip UUID16 since echoing such ids to the console can change the char set (under bash).

	for my $id (qw/AutoIncrement MD5 SHA1 SHA256 SHA512 Static UUID34 UUID36 UUID64/)
	{
		for my $serializer (qw/DataDumper FreezeThaw JSON Storable YAML/)
		{
			# Skip special cases (See FAQ):
			# o driver:File and ID::UUID64 (Invalid file name).
			# o driver:Pg and ID::UUID16 (Invalid UTF8).

			next if ( ($$config{dsn} =~ /dbi:File/) && ($id eq 'UUID64') );
			next if ( ($$config{dsn} =~ /dbi:Pg/) && ($id eq 'UUID16') );

			report("Test: $dsn_name. DSN: $$config{dsn}. ID generator: $id. Serializer: $serializer");

			$tester = run($config, $id, $serializer, \$test_count);
		}
	}
}

# For these tests, we don't care which tester object we ended up with.
# It's just we don't want to call these every time thru to loops above.
#
# Test generating a HTTP header with a cookie.

$test_count += $tester -> test_cookie_and_http_header;

# Test validation of time strings such as -10 +10d and 10M.

$test_count += $tester -> test_validation_of_time_strings;

# Test expiring a session and then reading it back in, to lose parameters.

$test_count += $tester -> test_expire_the_session;

# Test expiring a session parameter, and then reading it back in, to lose that parameter.

$test_count += $tester -> test_expire_a_session_parameter;

done_testing($test_count);
