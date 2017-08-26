file(GLOB_RECURSE CCODE_SOURCES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.vala")

set(MODULE_NAME ccode)

set(CCODE_VAPI_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
set(CCODE_VAPI ${CCODE_VAPI_DIR}/${MODULE_NAME}.vapi PARENT_SCOPE)

vala_precompile(VALA_C
	${CCODE_SOURCES}
LIBRARY
	${MODULE_NAME}
PACKAGES
    gobject-2.0
	gee
	config
OPTIONS
	--vapidir ${VAPI_DIR}
	--vapidir ${GEE_VAPI_DIR}
	--use-header
GENERATE_VAPI
	${CCODE_VAPI}
GENERATE_HEADER
    valaccode
)

add_library(${MODULE_NAME} ${VALA_C})
target_include_directories(${MODULE_NAME} PUBLIC
	${GEE_VAPI_DIR}
)
target_link_libraries(${MODULE_NAME}
	${GLIB_LIBRARIES}
	${GOBJECT_LIBRARIES}
	vala
)