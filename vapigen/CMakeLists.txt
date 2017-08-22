set(VAPIGEN_SOURCES
	valagidlparser.vala
	valavapigen.vala
)
set(VAPICHECK_SOURCES
	valavapicheck.vala
)

#set(MODULE_NAME vapigen)
#set(CCODE_VAPI_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
#set(CCODE_VAPI ${CCODE_VAPI_DIR}/${MODULE_NAME}.vapi PARENT_SCOPE)

vala_precompile(VALA_C
	${VAPIGEN_SOURCES}
PACKAGES
	gee vala gidl config
OPTIONS
	--vapidir ${VAPI_DIR}
	--vapidir ${GEE_VAPI_DIR}
	--vapidir ${VALA_VAPI_DIR}
	--vapidir ${GIDL_VAPI_DIR}
	--use-header
GENERATE_VAPI
	vapigen
GENERATE_HEADER
    vapigen
)

set(COMMON_INCLUDE_DIRS
	${GEE_VAPI_DIR}
	${VALA_VAPI_DIR}
	${GIDL_VAPI_DIR}
)
set(COMMON_LINK_LIBRARIES
	${GLIB_LIBRARIES}
	${GOBJECT_LIBRARIES}
	vala
	gidl
)

add_executable(vapigen ${VALA_C})
target_include_directories(vapigen PUBLIC ${COMMON_INCLUDE_DIRS})
target_link_libraries(vapigen ${COMMON_LINK_LIBRARIES})

vala_precompile(VALA_C
	${VAPICHECK_SOURCES}
PACKAGES
	gee vala gidl config
OPTIONS
	--vapidir ${VAPI_DIR}
	--vapidir ${GEE_VAPI_DIR}
	--vapidir ${VALA_VAPI_DIR}
	--vapidir ${GIDL_VAPI_DIR}
	--use-header
GENERATE_VAPI
	vapicheck
GENERATE_HEADER
    vapicheck
)

add_executable(vapicheck ${VALA_C})
target_include_directories(vapicheck PUBLIC ${COMMON_INCLUDE_DIRS})
target_link_libraries(vapicheck ${COMMON_LINK_LIBRARIES})