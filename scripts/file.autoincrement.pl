#!/usr/bin/perl

use common::sense;

use Data::Session;

use File::Temp;

# -----------------------------------------------

# The EXLOCK is for BSD-based systems.

my($data_source) = 'dbi:SQLite:dbname=/tmp/sessions.sqlite';
my($file_name)   = File::Temp -> new(EXLOCK => 0);
my($type)        = 'driver:File;id:AutoIncrement;serialize:DataDumper'; # Case-sensitive.

my($id);

{
my($session) = Data::Session -> new
(
	data_source => $data_source,
	id_base     => 99,
	id_file     => $file_name,
	id_step     => 2,
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
