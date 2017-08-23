# The "all tests" target, depending on valac
set(VALA_TESTS "vala_all_tests")
add_custom_target(${VALA_TESTS} ALL DEPENDS valac)

set(CTEST_TESTING_TIMEOUT 15)

set(TEST_DIRS
	annotations
	asynchronous
	basic-types
	chainup
	control-flow
	dbus
	delegates
	enums
	errors
	gir
	methods
	nullability
	objects
	pointers
	structs
)

# Tests to skip on Windows
set(WIN32_SKIP
	dbus/enum-string-marshalling
)

function(define_vala_test target_name)
	cmake_parse_arguments(ARGS "" "DIRECTORY;GENERATE_HEADER;GENERATE_VAPI"
        "INCLUDE_DIRS;LINK_LIBS;SOURCES;PACKAGES;OPTIONS;DEFINITIONS;CUSTOM_VAPIS" ${ARGN})
	
	set(INCLUDE_DIRS
		${GLIB_INCLUDE_DIRS}
		${GOBJECT_INCLUDE_DIRS}
		${GIO_INCLUDE_DIRS}
	)
	set(LINK_LIBS
		${GLIB_LIBRARIES}
		${GOBJECT_LIBRARIES}
		${GIO_LIBRARIES}
		m
	)
	set(PACKAGES gio-2.0)

	set(OPTIONS
		--disable-warnings
		--main main
		--save-temps
	)

	set(FLAGS
		-g
		-O0
		-DGETTEXT_PACKAGE=valac
		-Werror=return-type
		-Werror=init-self
		-Werror=implicit
		-Werror=sequence-point
		-Werror=return-type
		-Werror=uninitialized
		-Werror=pointer-arith
		-Werror=int-to-pointer-cast
		-Werror=pointer-to-int-cast
		-Wformat
		-Werror=format-security
		-Werror=format-nonliteral
		-Werror=redundant-decls
		-Werror=int-conversion
	)

	if(WIN32)
		list(APPEND OPTIONS -D WIN32)
		list(APPEND PACKAGES gio-windows-2.0)
	endif()

	# Extra include directories
	if(ARGS_INCLUDE_DIRS)
		LIST(APPEND ${INCLUDE_DIRS} ${ARGS_INCLUDE_DIRS})
	endif()

	# Extra link libraries
	if(ARGS_LINK_LIBS)
		LIST(APPEND ${LINK_LIBS} ${ARGS_LINK_LIBS})
	endif()

	# Extra packages
	if(ARGS_PACKAGES)
		LIST(APPEND ${PACKAGES} ${ARGS_PACKAGES})
	endif()

	# Extra options
	if(ARGS_OPTIONS)
		LIST(APPEND ${OPTIONS} ${ARGS_OPTIONS})
	endif()

	# The valac executable we just built
	set(VALAC_PATH $<TARGET_FILE:valac>)

	vala_precompile(VALA_C
		VALA_EXECUTABLE
			${VALAC_PATH}
		SOURCES
			${ARGS_SOURCES} ${ARGS_UNPARSED_ARGUMENTS}
		PACKAGES
			${PACKAGES}
		OPTIONS
			${OPTIONS}
		CUSTOM_VAPIS
			${ARGS_CUSTOM_VAPIS}
		GENERATE_VAPI
			${ARGS_GENERATE_VAPI}
		GENERATE_HEADER
			${ARGS_GENERATE_HEADER}
	)

	# Add "test_" prefix
	set(target_name "test_${target_name}")

	add_executable(${target_name} ${VALA_C})
	target_include_directories(${target_name} PUBLIC ${INCLUDE_DIRS})
	target_link_libraries(${target_name} ${LINK_LIBS})

	# Add this test to the "all tests" target
	add_dependencies(${VALA_TESTS} ${target_name})

	string (REPLACE ";" " " FLAGS_STR "${FLAGS}")
	set_target_properties(${target_name} PROPERTIES COMPILE_FLAGS "${FLAGS_STR}")

	#set(test_exe ${CMAKE_CURRENT_BINARY_DIR}/${target_name}${CMAKE_EXECUTABLE_SUFFIX})

	set(test_name ${target_name})

	#if(NOT ARGS_DIRECTORY)
	#	get_filename_component(basedir ${CMAKE_CURRENT_SOURCE_DIR} NAME)
	#	set(test_name "${basedir}/${test_name}")
	#endif()

	add_test(
		NAME
			${test_name}
		COMMAND
			${target_name}
		WORKING_DIRECTORY
			${CMAKE_CURRENT_BINARY_DIR}
	)
	set_tests_properties(${test_name} PROPERTIES
						TIMEOUT ${CTEST_TESTING_TIMEOUT})

endfunction()

macro(define_vala_tests)
	foreach(test ${ARGV})
		get_filename_component(name ${test} NAME_WE)
		define_vala_test(${name} ${test})
	endforeach()
endmacro()

## Discover tests
foreach(testdir ${TEST_DIRS})
	file(GLOB tests RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/${testdir}/*.vala")
	foreach(test_src ${tests})
		get_filename_component(name ${test_src} NAME_WE)

		# Should we skip this test?
		if(WIN32 AND ${testdir}/${name} IN_LIST WIN32_SKIP)
			continue()
		endif()

		define_vala_test(${testdir}_${name} ${test_src}
			DIRECTORY
		)
	endforeach()
endforeach()