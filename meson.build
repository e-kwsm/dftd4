# This file is part of dftd4.
# SPDX-Identifier: LGPL-3.0-or-later
#
# dftd4 is free software: you can redistribute it and/or modify it under
# the terms of the Lesser GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dftd4 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# Lesser GNU General Public License for more details.
#
# You should have received a copy of the Lesser GNU General Public License
# along with dftd4.  If not, see <https://www.gnu.org/licenses/>.

project(
  'dftd4',
  'fortran',
  version: '3.1.0',
  license: 'LGPL-3.0-or-later',
  meson_version: '>=0.53',
  default_options: [
    'buildtype=debugoptimized',
    'default_library=both',
  ],
)
install = not (meson.is_subproject() and get_option('default_library') == 'static')
has_cc = add_languages('c', required: get_option('python'))

# General configuration information
inc_dirs = []
lib_deps = []
subdir('config')

# Collect source of the project
srcs = []
subdir('src')

# Library target
dftd4_lib = library(
  meson.project_name(),
  sources: srcs,
  version: meson.project_version(),
  dependencies: lib_deps,
  include_directories: inc_dirs,
  install: install,
)

# Export dependency for other projects and test suite
dftd4_inc = [dftd4_lib.private_dir_include(), include_directories('include')]
dftd4_dep = declare_dependency(
  link_with: dftd4_lib,
  include_directories: dftd4_inc,
  dependencies: lib_deps,
)

# Add applications
subdir('app')

# Package the license files
dftd4_lic = files(
  'COPYING',
  'COPYING.LESSER',
)

dftd4_header = files(
  'include/dftd4.h',
)

if install
  # Distribute the license files in share/licenses/<name>
  install_data(
    dftd4_lic,
    install_dir: get_option('datadir')/'licenses'/meson.project_name()
  )

  install_headers(
    dftd4_header,
  )

  pkg = import('pkgconfig')
  pkg.generate(
    dftd4_lib,
    description: 'Generally Applicable Atomic-Charge Dependent London Dispersion Correction',
  )

  asciidoc = find_program('asciidoctor', required: false)
  if asciidoc.found()
    install_man(
      configure_file(
        command: [asciidoc, '-b', 'manpage', '@INPUT@', '-o', '@OUTPUT@'],
        input: files('man/dftd4.1.adoc'),
        output: '@BASENAME@',
      )
    )
  endif
endif

# add the testsuite
subdir('test')

if get_option('python')
  subdir('python'/'dftd4')
endif
