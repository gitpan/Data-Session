#!/usr/bin/perl

use common::sense;

use Data::Session;

use DBI;

# -----------------------------------------------

my($type)    = 'driver:SQLite;id:MD5;serialize:DataDumper';
my($dbh)     = DBI -> connect('dbi:SQLite:dbname=/tmp/sessions.sqlite');
my($session) = Data::Session -> new
(
	dbh     => $dbh,
	type    => $type,
	verbose => 0, # Affects parse_options().
) || die $Data::Session::errstr;

my($sub) = sub
{
	my($id) = @_;
	my($s)  = Data::Session -> new
	(
		dbh     => $dbh,
		id      => $id,
		type    => $type,
		verbose => 1, # Affects check_expiry() & parse_options().
	) || die $Data::Session::errstr;

	$s -> expire(-1);
	$s -> check_expiry;
};

$session -> traverse($sub);
