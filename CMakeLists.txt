cmake_minimum_required(VERSION 3.3)

project(Vala C)
set(VALA_VERSION 0.38)

list(APPEND CMAKE_MODULE_PATH
	${CMAKE_SOURCE_DIR}/cmake
	${CMAKE_SOURCE_DIR}/cmake/vala
)

if(CMAKE_BUILD_TYPE STREQUAL "")
	set(CMAKE_BUILD_TYPE "Debug")
endif()

include(FindVala)
include(UseVala)

include(Utils)

include(CheckIncludeFiles)
include(CMakeDependentOption)
include(CTest)

find_package(Vala REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(Bison REQUIRED)
find_package(Flex REQUIRED)

set(GLIB_VERSION 2.40.0)
set(LIBGVC_VERSION 2.16)

pkg_check_modules(GLIB REQUIRED glib-2.0>=${GLIB_VERSION})
pkg_check_modules(GOBJECT REQUIRED gobject-2.0>=${GLIB_VERSION})
pkg_check_modules(GMODULE REQUIRED gmodule-2.0>=${GLIB_VERSION})
pkg_check_modules(LIBGVC libgvc>=${LIBGVC_VERSION})

pkg_check_modules(GIO REQUIRED gio-2.0>=${GLIB_VERSION})
if(WIN32)
	pkg_check_modules(GIO_WINDOWS REQUIRED gio-windows-2.0>=${GLIB_VERSION})
endif()

include_directories(
	${GLIB_INCLUDE_DIRS}
	${GMODULE_INCLUDE_DIRS}
	${GOBJECT_INCLUDE_DIRS}
	${LIBGVC_INCLUDE_DIRS}
	${GIO_INCLUDE_DIRS}
	${GIO_WINDOWS_INCLUDE_DIRS}
)

link_directories(
	${GLIB_LIBRARY_DIRS}
	${GMODULE_LIBRARY_DIRS}
	${GOBJECT_LIBRARY_DIRS}
	${LIBGVC_LIBRARY_DIRS}
	${GIO_LIBRARY_DIRS}
	${GIO_WINDOWS_LIBRARY_DIRS}
)

option(ENABLE_DOC "Set to ON to build documentation" OFF)
option(ENABLE_LIBVALADOC, "Set to ON to build libvaladoc" OFF)
option(ENABLE_TESTS "Set to ON to build and run tests" OFF)
option(ENABLE_GPROF "Set to ON to enable gprof" OFF)
option(GENERATE_VAPIS "Set to ON to generate vapi files" OFF)
set(VALA_BUILD_VERSION "UNKNOWN" CACHE STRING "Build Version (will appear in --version)")

if(ENABLE_GPROF)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pg")
endif()

# Vala looks VAPIs up in the install prefix
# Default to an in-tree build if no install prefix was specified
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}" CACHE PATH "default install path" FORCE )
endif()

if(ENABLE_DOC)
	set(ENABLE_LIBVALADOC ON)
	check_include_files(gvc.h HAVE_CGRAPH)
endif()

configure_file(
	${CMAKE_CURRENT_SOURCE_DIR}/vala-config.h.in
	${CMAKE_CURRENT_BINARY_DIR}/config.h
)
## TODO: either a separate file or make Vala include config.h only
configure_file(
	${CMAKE_CURRENT_BINARY_DIR}/config.h
	${CMAKE_CURRENT_BINARY_DIR}/version.h
	COPYONLY
)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(VAPI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/vapi)

add_subdirectory(gee)
add_subdirectory(gobject-introspection)

add_subdirectory(ccode)
add_subdirectory(vala)
add_subdirectory(codegen)
add_subdirectory(compiler)
add_subdirectory(vapigen)

if(GENERATE_VAPIS)
	add_subdirectory(vapi)
endif()

if(ENABLE_DOC)
	add_subdirectory(doc)
	add_subdirectory(libvaladoc)
	add_subdirectory(valadoc)
endif()
if(ENABLE_TESTS)
	enable_testing()
	add_subdirectory(tests)
endif()