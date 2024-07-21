AUTOMAKE_OPTIONS = foreign

ACLOCAL_AMFLAGS = -I m4

bin_SCRIPTS = reverse-string.sh find-overlap.sh

AM_CPPFLAGS = $(DEFAULT_CPPFLAGS)
AM_CFLAGS = $(DEFAULT_CFLAGS)

bin_PROGRAMS = delete-chars

# bin_PROGRAMS_DEPENDENCIES = Makefile
# bin_PROGRAMS_SOURCES = delete-chars.c

EXTRA_DIST = bootstrap configure.ac COPYING m4 mit-plus-license.txt README.md \
	version.sh $(addsuffix .in, $(bin_SCRIPTS))

MAINTAINERCLEANFILES = aclocal.m4 compile config.h* configure depcomp \
 install-sh Makefile.in missing $(PACKAGE)-*.gz

maintainer-clean-local:
	rm -rf m4 .deps

.PHONY: help

help:
	@echo "Targets:"
	@echo "  make install"
	@echo "  make dist"
	@echo "  make distcheck"
	@echo "  make distclean"
	@echo "  make maintainer-clean"
