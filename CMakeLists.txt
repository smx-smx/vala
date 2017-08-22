cmake_minimum_required(VERSION 2.8) #unsure about this

project(Vala C)
set(VALA_VERSION 0.38)

list(APPEND CMAKE_MODULE_PATH
	${CMAKE_SOURCE_DIR}/cmake/vala
)

if(CMAKE_BUILD_TYPE STREQUAL "")
	set(CMAKE_BUILD_TYPE "Debug")
endif()

include(FindVala)
include(UseVala)

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

include_directories(
	${GLIB_INCLUDE_DIRS}
	${GMODULE_INCLUDE_DIRS}
	${GOBJECT_INCLUDE_DIRS}
	${LIBGVC_INCLUDE_DIRS}
)

link_directories(
	${GLIB_LIBRARY_DIRS}
	${GMODULE_LIBRARY_DIRS}
	${GOBJECT_LIBRARY_DIRS}
	${LIBGVC_LIBRARY_DIRS}
)

option(ENABLE_DOC "Set to ON to build documentation" OFF)
option(ENABLE_LIBVALADOC, "Set to ON to build libvaladoc" OFF)
option(ENABLE_TESTS "Set to ON to build and run tests" OFF)
set(VALA_BUILD_VERSION "UNKNOWN" CACHE STRING "Build Version (will appear in --version)")

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
add_subdirectory(vapi)

if(ENABLE_DOC)
	add_subdirectory(doc)
	add_subdirectory(libvaladoc)
	add_subdirectory(valadoc)
endif()
if(ENABLE_TESTS)
	enable_testing()
	add_subdirectory(tests)
endif()

add_subdirectory(vapigen)