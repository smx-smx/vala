set(VALAC_SOURCES
	valacompiler.vala
)

set(MODULE_NAME valac)

set(COMPILER_VAPI_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
set(COMPILER_VAPI ${COMPILER_VAPI_DIR}/${MODULE_NAME}.vapi PARENT_SCOPE)

vala_precompile(VALA_C
	${VALAC_SOURCES}
PACKAGES
    gobject-2.0
	gee
	ccode
	vala
	codegen
	config
OPTIONS
	--vapidir ${VAPI_DIR}
	--vapidir ${GEE_VAPI_DIR}
	--vapidir ${CCODE_VAPI_DIR}
	--vapidir ${VALA_VAPI_DIR}
	--vapidir ${CODEGEN_VAPI_DIR}
	--use-header
GENERATE_VAPI
	${CCODE_VAPI}
GENERATE_HEADER
    ${MODULE_NAME}
)

add_executable(${MODULE_NAME} ${VALA_C})
target_include_directories(${MODULE_NAME} PUBLIC
	${GEE_VAPI_DIR}
	${CCODE_VAPI_DIR}
	${VALA_VAPI_DIR}
	${CODEGEN_VAPI_DIR}
)
target_link_libraries(${MODULE_NAME}
	${GLIB_LIBRARIES}
	${GOBJECT_LIBRARIES}
	vala
	ccode
	codegen
)