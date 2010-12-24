package Data::Session::Base;

no autovivification;
use common::sense;
use warnings 'uninitialized';

use Hash::FieldHash ':all';

fieldhash my %cache             => 'cache';
fieldhash my %data_col_name     => 'data_col_name';
fieldhash my %data_source       => 'data_source';
fieldhash my %data_source_attr  => 'data_source_attr';
fieldhash my %dbh               => 'dbh';
fieldhash my %deleted           => 'deleted';
fieldhash my %directory         => 'directory';
fieldhash my %driver_cless      => 'driver_class';
fieldhash my %driver_option     => 'driver_option';
fieldhash my %expired           => 'expired';
fieldhash my %file_name         => 'file_name';
fieldhash my %host              => 'host';
fieldhash my %id                => 'id';
fieldhash my %id_base           => 'id_base';
fieldhash my %id_col_name       => 'id_col_name';
fieldhash my %id_file           => 'id_file';
fieldhash my %id_class          => 'id_class';
fieldhash my %id_option         => 'id_option';
fieldhash my %id_step           => 'id_step';
fieldhash my %is_new            => 'is_new';
fieldhash my %modified          => 'modified';
fieldhash my %name              => 'name';
fieldhash my %no_flock          => 'no_flock';
fieldhash my %no_follow         => 'no_follow';
fieldhash my %password          => 'password';
fieldhash my %pg_bytea          => 'pg_bytea';
fieldhash my %pg_text           => 'pg_text';
fieldhash my %port              => 'port';
fieldhash my %query             => 'query';
fieldhash my %query_class       => 'query_class';
fieldhash my %serializer_class  => 'serializer_class';
fieldhash my %serializer_option => 'serializer_option';
fieldhash my %session           => 'session';
fieldhash my %socket            => 'socket';
fieldhash my %table_name        => 'table_name';
fieldhash my %type              => 'type';
fieldhash my %umask             => 'umask';
fieldhash my %username          => 'username';
fieldhash my %verbose           => 'verbose';

our $errstr  = '';
our $VERSION = '1.03';

# -----------------------------------------------

sub log
{
	my($self, $s) = @_;
	$s ||= '';

	print STDERR "# $s\n";

} # End of log.

# -----------------------------------------------

1;
