file(GLOB_RECURSE VALA_SOURCES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.vala")

set(MODULE_NAME vala)

set(VALA_VAPI_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
set(VALA_VAPI ${VALA_VAPI_DIR}/${MODULE_NAME}.vapi PARENT_SCOPE)

vala_precompile(VALA_C
	${VALA_SOURCES}
LIBRARY
	${MODULE_NAME}
PACKAGES
	gmodule-2.0
    gobject-2.0
	gee
	config
OPTIONS
	--vapidir ${VAPI_DIR}
	--vapidir ${GEE_VAPI_DIR}
	--use-header
GENERATE_VAPI
    ${VALA_VAPI}
GENERATE_HEADER
    ${MODULE_NAME}
)

add_library(${MODULE_NAME} ${VALA_C})
target_include_directories(${MODULE_NAME} PUBLIC
	${GEE_VAPI_DIR}
	${CCODE_VAPI_DIR}
)
target_link_libraries(${MODULE_NAME}
	${GLIB_LIBRARIES}
	${GOBJECT_LIBRARIES}
	${GMODULE_LIBRARIES}
	gee
)