set(VAPI_PACKAGES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/packages")
set(VAPI_METADATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/metadata")

# The "all vapis" target, depending on vapigen
set(VALA_VAPIS "vala_all_vapis")
add_custom_target(${VALA_VAPIS} ALL DEPENDS vapigen)

pkg_check_variable(gobject-introspection-1.0 girdir)
set(VAPI_GIR_DIR "${GOBJECT_INTROSPECTION_1.0_GIRDIR}")

function(add_vapi name)
	# Output vapis in the source tree
	set(VAPI_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR})

	cmake_parse_arguments(ARGS "" "LIBRARY"
        "PACKAGES" ${ARGN})

	set(vala_pkg_opts "")
    foreach(pkg ${ARGS_PACKAGES})
        list(APPEND vala_pkg_opts "--pkg=${pkg}")
    endforeach(pkg ${ARGS_PACKAGES})

	set(target_name "vapi_${name}")

	set(vapigen_out
		${name}.vapi
		${name}.deps
	)

	add_custom_command(
		OUTPUT
			${vapigen_out}
		COMMAND
			vapigen
			--library ${CMAKE_CURRENT_SOURCE_DIR}/${name}
			--metadatadir ${VAPI_METADATA_DIR}
			-d ${VAPI_OUT_DIR}
			${vala_pkg_opts}
			${ARGS_UNPARSED_ARGUMENTS}
	)
	add_custom_target(${target_name} ALL DEPENDS ${vapigen_out})

	add_dependencies(${VALA_VAPIS} ${target_name})
endfunction()

include (vapi.cmake)