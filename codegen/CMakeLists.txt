file(GLOB_RECURSE CODEGEN_SOURCES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.vala")

set(MODULE_NAME codegen)

set(CODEGEN_VAPI_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
set(CODEGEN_VAPI ${VALA_VAPI_DIR}/${MODULE_NAME}.vapi PARENT_SCOPE)

vala_precompile(VALA_C
	${CODEGEN_SOURCES}
LIBRARY
	${MODULE_NAME}
PACKAGES
    gobject-2.0
	gee
	ccode
	vala
OPTIONS
	--vapidir ${VAPI_DIR}
	--vapidir ${GEE_VAPI_DIR}
	--vapidir ${CCODE_VAPI_DIR}
	--vapidir ${VALA_VAPI_DIR}
	--use-header
GENERATE_VAPI
	${CODEGEN_VAPI}
GENERATE_HEADER
    valacodegen
)

add_library(${MODULE_NAME} ${VALA_C})
target_include_directories(${MODULE_NAME} PUBLIC
	${GEE_VAPI_DIR}
	${CCODE_VAPI_DIR}
	${VALA_VAPI_DIR}
)
target_link_libraries(${MODULE_NAME}
	${GLIB_LIBRARIES}
	${GOBJECT_LIBRARIES}
	vala
	ccode
)