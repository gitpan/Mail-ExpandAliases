package Mail::ExpandAliases;

# ----------------------------------------------------------------------
# $Id: Makefile.PL,v 1.3 2002/09/24 17:06:46 dlc Exp $
# ----------------------------------------------------------------------
# Makefile.PL - Generate a Makefile
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
# ----------------------------------------------------------------------

use strict;
use vars qw($VERSION @EXE_FILES %PREREQ_PM %clean);

use ExtUtils::MakeMaker;
use File::Basename qw(basename);

$VERSION   = sprintf "%.02f", 0.15;
@EXE_FILES = ('expand-alias');
%PREREQ_PM = ('IO::File');
%clean     = ('FILES' => '$(DISTNAME)-$(VERSION).tar.gz');

WriteMakefile(
    NAME         => __PACKAGE__,
    VERSION_FROM => basename($0),
    EXE_FILES    => \@EXE_FILES,
    PREREQ_PM    => \%PREREQ_PM,
    clean        => \%clean,
);

__END__
