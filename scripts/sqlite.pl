#!/usr/bin/perl

use common::sense;

use Data::Session;

# -----------------------------------------------

my($data_source) = 'dbi:SQLite:dbname=/tmp/sessions.sqlite';
my($type)        = 'driver:SQLite;id:SHA1;serialize:DataDumper'; # Case-sensitive.

my($id);

{
my($session) = Data::Session -> new
(
	data_source => $data_source,
	type        => $type,
) || die $Data::Session::errstr;

$id = $session -> id;

$session -> param(a_key => 'a_value');

print "Id: $id. Save a_key: a_value. \n";
}

{
my($session) = Data::Session -> new
(
	data_source => $data_source,
	id          => $id,
	type        => $type,
) || die $Data::Session::errstr;

print "Id: $id. Recover a_key: ", $session -> param('a_key'), ". \n";

$session -> delete;
}
