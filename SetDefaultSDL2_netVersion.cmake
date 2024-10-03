# include(SetDefaultSDL2_netVersion)
#   queries system package manager to get default version of SDL2_net library,
#     caching SDL2_NET_DEFAULT_VERSION in <major>.<minor>.<patch> format

# newest feature used: if(DEFINED CACHE{}) v3.14
cmake_minimum_required(VERSION 3.14)

include_guard(DIRECTORY)

if(DEFINED CACHE{SDL2_NET_DEFAULT_VERSION})
  return()
endif()

if(NOT COMMAND determine_package_manager)
  include(DeterminePackageManager)
endif()

if(NOT COMMAND default_package_version)
  include(DefaultPackageVersion)
endif()

if(NOT COMMAND upstream_ver_from_package_ver)
  include(UpstreamVerFromPackageVer)
endif()

if(NOT PACKAGE_MANAGER_BINARY)
  determine_package_manager()
endif()

unset(_SDL2_NET_DEFAULT_VERSION)

if(${PACKAGE_MANAGER_BINARY} MATCHES "/brew$")

  # MacOS: homebrew
  default_package_version("sdl2_net"          _SDL2_NET_DEFAULT_VERSION)

elseif(${PACKAGE_MANAGER_BINARY} MATCHES "/aptitude$" OR
    ${PACKAGE_MANAGER_BINARY} MATCHES "/apt$")

  # Debian: aptitude > apt [> dpkg]
  default_package_version("libsdl2-net-2.0-0" _SDL2_NET_DEFAULT_VERSION)

elseif(${PACKAGE_MANAGER_BINARY} MATCHES "/dnf$" OR
    ${PACKAGE_MANAGER_BINARY} MATCHES "/yum$")

  # RHEL: dnf > yum [> rpm]
  default_package_version("SDL2_net"          _SDL2_NET_DEFAULT_VERSION)

elseif(${PACKAGE_MANAGER_BINARY} MATCHES "/pacman$")

  # Arch: pacman
  default_package_version("sdl2_net"          _SDL2_NET_DEFAULT_VERSION)

elseif(${PACKAGE_MANAGER_BINARY} MATCHES "/emerge")

  # Gentoo: portage (emerge)
  default_package_version("sdl2-net"          _SDL2_NET_DEFAULT_VERSION)

elseif(${PACKAGE_MANAGER_BINARY} MATCHES "/zypper$")

  # openSUSE: zypper [> rpm]
  # note: passing "" to `zypper info` will list all packages
  default_package_version("libSDL2_net-2_0-0" _SDL2_NET_DEFAULT_VERSION)

else()
  message(WARNING "`${PACKAGE_MANAGER_BINARY}` is unsupported package manager")
endif()

if(${_SDL2_NET_DEFAULT_VERSION})
  upstream_ver_from_package_ver(
    "${_SDL2_NET_DEFAULT_VERSION}" _SDL2_NET_DEFAULT_VERSION)
  # upstream version according to package manager may still have suffixes,
  #    eg "+dfsg" or "+hg695". Here we strip all else away to get the
  #    <major>.<minor>.<patch> version used by Catch2 repository tags.
  # (double backslashes for cmake argument parsing)
  string(REGEX REPLACE
    "^([0-9]+\\.[0-9]+\\.[0-9]+).*$" "\\1"
    _SDL2_NET_DEFAULT_VERSION "${_SDL2_NET_DEFAULT_VERSION}")
endif()

set(SDL2_NET_DEFAULT_VERSION "${_SDL2_NET_DEFAULT_VERSION}" CACHE STRING
  "default SDL2_net package version in <major>.<minor>.<patch> format")
unset(_SDL2_NET_DEFAULT_VERSION)
