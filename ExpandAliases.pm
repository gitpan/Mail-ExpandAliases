package Mail::ExpandAliases;

# -------------------------------------------------------------------
# $Id: ExpandAliases.pm,v 1.2 2002/09/24 11:01:16 dlc Exp $
# -------------------------------------------------------------------
# Mail::ExpandAliases - Expand aliases from /etc/aliases files 
# Copyright (C) 2002 darren chamberlain <darren@cpan.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307  USA
# -------------------------------------------------------------------

use strict;
use vars qw($VERSION);

$VERSION = 0.14;

use constant PARSED => 0;
use constant CACHED => 1;
use constant FILE   => 2;
use constant SEEN   => 3;

sub new {
    my ($class, $file) = @_;
    my $self = bless [ { }, { }, $file, { } ] => $class;

    $self->parse;

    return $self;
}

sub parse {
    my $self = shift;
    my $file = shift || $self->[ FILE ];
    return if $self->[ SEEN ]->{ $file }++ == 1;

    # File::Aliases is an internal module; I hope this doesn't
    # actually exist!
    my $fh = File::Aliases->new($file);

    while (local $_ = $fh->next) {
        chomp;      # trailing newlines
        s/^\s*//;   # leading spaces
        s/\s*$//;   # trailing spaces
        s/#.*//;    # comments
        next unless length; # skip blanks

        if (/:include:\s*(.*)/i) {
            $self->parse($1);
            next;
        }

        my ($alias, @expandos) = split /[:,]\s*/;
        $self->[ PARSED ]->{ $alias } = \@expandos;
    }

    return $self;
}

sub expand {
    my ($self, $name, @names, @answers, $n);
    $self = shift;
    $name = shift || return $name;

    if (@names = @{ $self->[ CACHED ]->{ $name } ||= [ ] }) {
        return wantarray ? @names : \@names;
    }

    if (@names = @{ $self->[ PARSED ]->{ $name } || [ ] }) {
        for $n (@names) {
            push @answers, $self->expand($n);
        }

        $self->[ CACHED ]->{ $name } = \@answers;
        return wantarray ? @answers : \@answers;
    }

    return $name;
}

sub reload {
    my ($self, $file) = @_;

    %{ $self->[ PARSED ] } = ();
    %{ $self->[ CACHED ] } = ();
    $self->[ FILE ] = $file if defined $file;

    $self->parse;

    return $self;
}

package File::Aliases;
use IO::File;
use enum qw(FH BUFFER);

# This package ensures that each read (i.e., calls to next() --
# I'm too lazy to implement this as a tied file handle so it can
# be used in <>) returns a single alias entry, which may span
# multiple lines.

sub new {
    my $class = shift;
    my $file = shift;
    my $fh = IO::File->new($file);

    my $self = bless [ $fh, '' ] => $class;
    $self->[ BUFFER ] = <$fh>;

    return $self;
}

sub next {
    my $self = shift;
    my $buffer = $self->[ BUFFER ];
    my $fh = $self->[ FH ];

    $self->[ BUFFER ] = "";
    while (<$fh>) {
        if (/^\S/) {
            $self->[ BUFFER ] = $_;
            last;
        } else {
            $buffer .= $_;
        }
    }

    return $buffer;
}

1;

__END__

=head1 NAME

Mail::ExpandAliases - Expand aliases from /etc/aliases files

=head1 SYNOPSIS

    use Mail::ExpandAliases;

    my $ma = Mail::ExpandAliases->new("/etc/aliases");
    my @list = $ma->expand("listname");

=head1 DESCRIPTION

I've looked for software to expand aliases from an alias file for a
while, but have never found anything adequate.  In this day and age,
few public SMTP servers support EXPN, which makes alias expansion
problematic.  This module, and the accompanying C<expand-alias>
script, attempts to address that deficiency.

=head1 USAGE

Mail::ExpandAliases is an object oriented module, with a constructor
named C<new>:

    my $ma = Mail::ExpandAliases->new("/etc/mail/aliases");

C<new> takes the filename of an aliases file; if not supplied, or if
the file specified does not exist or is not readable,
Mail::ExpandAliases will look for /etc/aliases and /etc/mail/aliases,
and use the first one found.

Lookups are made using the C<expand> method:

    @aliases = $ma->expand("listname");

C<expand> returns a list of expanded addresses.  These expanded
addresses are also expanded, whenever possible.

A non-expandible alias (no entry in the aliases file) expands to
itself, i.e., does not expand.

In scalar context, C<expand> returns a reference to a list.

Note that Mail::ExpandAliases provides read-only access to the alias
file.  If you are looking for read access, see Mail::Alias, which is a
more general interface to alias files.

=head1 BUGS / SHORTCOMINGS

If you were telnet mailhost 25, and the server had EXPN turned on, the
sendmail would read a user's .forward file.  This software cannot do
that, and makes no attempt to.  Only the invoking user's .forward file
should be readable (if any other user's .forward file was readable,
sendmail would not read it, making this feature useless), and the
invoking user should not need this module to read their own .forward
file.

Any other shortcomings, bugs, errors, or generally related complaints
and requests should be reported via the appropriate queue at
<http://rt.cpan.org/>.

=head1 VERSION

$Id: ExpandAliases.pm,v 1.2 2002/09/24 11:01:16 dlc Exp $

=head1 AUTHOR

darren chamberlain E<lt>darren@cpan.orgE<gt>
