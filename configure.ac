## configure.ac -- Process this file with autoconf to produce configure
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; version 2 of the License.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

AC_INIT([that-code],
    [m4_esyscmd_s([./version.sh])])

AC_USE_SYSTEM_EXTENSIONS

AC_CONFIG_MACRO_DIR([m4])

AC_PREFIX_DEFAULT([/usr/local])

AS_IF([test "x$CFLAGS" = "x"], [AC_SUBST([CFLAGS], [""])])

AC_PROG_CC
AC_PROG_INSTALL

AM_INIT_AUTOMAKE
AC_USE_SYSTEM_EXTENSIONS

AM_SILENT_RULES([yes])

default_cflags="--std=gnu99 -g \
	-Wall -W -Wunused -Wstrict-prototypes -Wmissing-prototypes \
	-Wmissing-declarations -Wredundant-decls -Werror"

default_cppflags=""

AC_ARG_ENABLE(
	[debug],
	[AS_HELP_STRING([--enable-debug],
		[build programs with extra debug info [default=no]]
	)],
	[],
	[enable_debug=check]
)

AS_IF(
	[test "x$enable_debug" = "xyes"],
	[
		default_cflags="$default_cflags -O0 -ggdb"
		default_cppflags="$default_cppflags -DDEBUG"
	],
	[
		default_cflags="$default_cflags -O2"
		default_cppflags="$default_cppflags -DNDEBUG"
	]
)

AC_SUBST([DEFAULT_CFLAGS], ["$default_cflags"])
AC_SUBST([DEFAULT_CPPFLAGS], ["$default_cppflags"])

AC_SUBST([DESTDIR])

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile])

AC_OUTPUT
