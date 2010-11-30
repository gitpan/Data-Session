#!/usr/bin/perl

use common::sense;
use lib 't';

use DBI;

use File::Temp;

use Test;

use DBIx::Admin::DSNManager;

use Test::More;

use Try::Tiny;

# -----------------------------------------------

sub BEGIN { use_ok('Data::Session'); }

# -----------------------------------------------

sub run
{
	my($id, $serializer, $config, $test_count) = @_;

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

		# The EXLOCK option is for BSD-based systems.

		$directory = File::Temp::newdir('temp.XXXX', CLEANUP => 1, EXLOCK => 0, TMPDIR => 1);
		$type      = "driver:$dsn[1];id:$id;serialize:$serializer";
		$tester    = Test -> new
		(
			directory => $directory,
			dsn       => $$config{dsn},
			dsn_attr  => $$config{attributes},
			password  => $$config{password},
			type      => $type,
			username  => $$config{username},
			verbose   => 1,
		);

		subtest $type => sub
		{
			$$test_count += $tester -> traverse;
		};
	}
	catch
	{
		# This extra call to done_testing just stops an extra error message.

		done_testing($$test_count);
		BAIL_OUT($_);
	}

} # End of run.

# -----------------------------------------------

sub report
{
	my($s) = @_;

	print STDERR "# $s\n";

} # End of report.

# -----------------------------------------------

my($dsn_config) = DBIx::Admin::DSNManager -> new(file_name => 't/basic.ini') -> config;
my($test_count) = 1; # The use_ok in BEGIN counts as the first test.

my($config);

# We skip UUID16 since echoing such ids to the console can change the char set.

for my $id (qw/MD5/)
{
	for my $serializer (qw/DataDumper/)
	{
		for my $dsn_name (sort keys %$dsn_config)
		{
			$config = $$dsn_config{$dsn_name};

			next if ( ($$config{active} == 0) || ($$config{use_for_testing} == 0) );

			report("DSN name: $dsn_name. DSN: $$config{dsn}. ID generator: $id. Serializer: $serializer");

			run($id, $serializer, $config, \$test_count);
		}
	}
}

done_testing($test_count);
