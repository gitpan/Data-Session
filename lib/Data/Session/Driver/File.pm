package Data::Session::Driver::File;

use parent 'Data::Session::Base';
no autovivification;
use common::sense;
use warnings 'uninitialized';

use Fcntl qw/:DEFAULT :flock :mode/;

use File::Path;
use File::Spec;

use Hash::FieldHash ':all';

use Try::Tiny;

our $VERSION = '1.02';

# -----------------------------------------------

sub get_file_path
{
	my($self, $sid) = @_;
	(my $id = $sid) =~ s|\\|/|g;

	($id =~ m|/|) && die __PACKAGE__ . ". Session ids cannot contain \\ or /: '$sid'";

    return File::Spec -> catfile($self -> directory, sprintf($self -> file_name, $sid) );

} # End of get_file_path.

# -----------------------------------------------

sub init
{
	my($self, $arg)  = @_;
	$$arg{directory} ||= File::Spec -> tmpdir;
	$$arg{file_name} ||= 'cgisess_%s';
	$$arg{id}        ||= 0;
	$$arg{no_flock}  ||= 0;
	$$arg{no_follow} ||= eval { O_NOFOLLOW } || 0;
	$$arg{umask}     ||= 0660;
	$$arg{verbose}   ||= 0;

} # End of init.

# -----------------------------------------------

sub new
{
	my($class, %arg) = @_;

	$class -> init(\%arg);

	my($self)  = from_hash(bless({}, $class), \%arg);

	($self -> file_name !~ /%s/) && die __PACKAGE__ . ". file_name must contain %s";

	if (! -d $self -> directory)
	{
		if (! File::Path::mkpath($self -> directory) )
		{
			die __PACKAGE__ . ". Can't create directory '" . $self -> directory . "'";
		}
	}

	return $self;

} # End of new.

# -----------------------------------------------

sub remove
{
	my($self, $id) = @_;
	my($file_path) = $self -> get_file_path($id);

	unlink $file_path || die __PACKAGE__ . ". Can't remove file '$file_path'";

	return 1;

} # End of remove.

# -----------------------------------------------

sub retrieve
{
	my($self, $id) = @_;
	my($file_path) = $self -> get_file_path($id);
	my($message)   = __PACKAGE__ . ". Can't %s file: " . $self -> get_file_path($id);

	(! -e $file_path) && return '';

	# Remove symlinks if possible.

	if (-l $file_path)
	{
		unlink($file_path) || die sprintf($message, 'unlink');
	}

	my($mode) = (O_RDONLY | $self -> no_follow);

	my($fh);

	sysopen($fh, $file_path, $mode, $self -> umask) || die sprintf($message, 'open');

	# Sanity check.

	(-l $file_path) && die sprintf($message, 'open non-link file');

	if (! $self -> no_flock)
	{
		flock($fh, LOCK_EX) || die sprintf($message, 'lock');
	}

	my($data) = '';

	while (<$fh>)
	{
		$data .= $_;
	}

	close($fh) || die sprintf($message, 'close');

	return $data;

} # End of retrieve.

# -----------------------------------------------

sub store
{
	my($self, $id, $data) = @_;
	my($file_path) = $self -> get_file_path($id);
	my($message)   = __PACKAGE__ . ". Can't %s file: " . $self -> get_file_path($id);

	# Remove symlinks if possible.

	if (-l $file_path)
	{
		unlink($file_path) || die sprintf($message, 'unlink');
	}

	my($mode) = -e $file_path ? (O_WRONLY | $self -> no_follow) : (O_RDWR | O_CREAT | O_EXCL);

	my($fh);

	sysopen($fh, $file_path, $mode, $self -> umask) || die sprintf($message, 'open');

	# Sanity check.

	(-l $file_path) && die sprintf($message, 'create non-link');

	if (! $self -> no_flock)
	{
		flock($fh, LOCK_EX) || die sprintf($message, 'lock');
	}

	seek($fh, 0, 0)  || die sprintf($message, 'seek');
	truncate($fh, 0) || die sprintf($message, 'truncate');
	print $fh $data;
	close($fh) || die sprintf($message, 'close');

	return 1;

} # End of store.

# -----------------------------------------------

sub traverse
{
	my($self, $sub) = @_;

	if (! $sub || ref($sub) ne 'CODE')
	{
		die __PACKAGE__ . '. traverse() called without subref';
	}

	my($pattern) = $self -> file_name;
	$pattern     =~ s/\./\\./g; # Or /\Q.../.
	$pattern     =~ s/%s/(\.\+)/;
	my($message) = __PACKAGE__ . ". Can't open dir '" . $self -> directory . "' in traverse";

	opendir(INX, $self -> directory) || die $message;

	my($entry);

	while ($entry = readdir(INX) )
	{
		next if ($entry =~ /^\.\.?/ || -d $entry);

		($entry =~ /$pattern/) && $sub -> ($1);
	}

	closedir(INX);

	return 1;

} # End of traverse.

# -----------------------------------------------

1;

=pod

=head1 NAME

L<Data::Session::Driver::File> - A persistent session manager

=head1 Synopsis

See L<Data::Session> for details.

=head1 Description

L<Data::Session::Driver::File> allows L<Data::Session> to manipulate sessions via files.

To use this module do this:

=over 4

=item o Specify a driver of type File, as Data::Session -> new(type => 'driver:File ...')

=back

=head1 Case-sensitive Options

See L<Data::Session/Case-sensitive Options> for important information.

=head1 Method: new()

Creates a new object of type L<Data::Session::Driver::File>.

C<new()> takes a hash of key/value pairs, some of which might mandatory. Further, some combinations
might be mandatory.

The keys are listed here in alphabetical order.

They are lower-case because they are (also) method names, meaning they can be called to set or get the value
at any time.

=over 4

=item o directory => $string

Specifies the path to the directory which will contain the session files.

This key is normally passed in as Data::Session -> new(directory => $string).

The default value is File::Spec -> tmpdir.

This key is optional.

=item o file_name => $string_containing_%s

Specifies the pattern to use for session file names. It must contain 1 '%s', which will be replaced by the
session id before the pattern is used as a file name.

This key is normally passed in as Data::Session -> new(file_name => $string_containing_%s).

The default value is 'cgisess_%s'.

This key is optional.

=item o no_flock => $boolean

Specifies (no_flock => 1) to not use flock() to obtain a lock on a session file before processing it,
or (no_flock => 0) to use flock().

This key is normally passed in as Data::Session -> new(no_flock => $boolean).

The default value is 0.

This key is optional.

=item o no_follow => $value

Influences the mode to use when calling sysopen() on session files.

'Influences' means the value is bit-wise ored with O_RDONLY for reading and with O_WRONLY for writing.

This key is normally passed in as Data::Session -> new(no_follow => $boolean).

The default value is eval{O_NOFOLLOW} || 0.

This key is optional.

=item o umask => $octal_value

Specifies the mode to use when calling sysopen() on session files.

This key is normally passed in as Data::Session -> new(umask => $octal_value).

The default value is 0660.

This key is optional.

=item o verbose => $integer

Print to STDERR more or less information.

Typical values are 0, 1 and 2.

This key is normally passed in as Data::Session -> new(verbose => $integer).

This key is optional.

=back

=head1 Method: remove($id)

Deletes from storage the session identified by $id.

Returns 1 if it succeeds, and dies if it can't.

=head1 Method: retrieve($id)

Retrieves from storage the session identified by $id, or dies if it can't.

Returns the result of reading the session from the file identified by $id.

This result is a frozen session. This value must be thawed by calling the appropriate serialization
driver's thaw() method.

L<Data::Session> calls the right thaw() automatically.

=head1 Method: store($id => $data)

Writes to storage the session identified by $id, together with its data $data.

Storage is a file identified by $id.

Returns 1 if it succeeds, and dies if it can't.

=head1 Method: traverse($sub)

Retrieves all ids via their file names, and for each id calls the supplied subroutine with the id as the only
parameter.

Returns 1.

=head1 Support

Log a bug on RT: L<https://rt.cpan.org/Public/Dist/Display.html?Name=Data-Session>.

=head1 Author

L<Data::Session> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2010.

Home page: L<http://savage.net.au/index.html>.

=head1 Copyright

Australian copyright (c) 2010, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
