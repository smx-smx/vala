set(GIDL_SOURCES
	gidlmodule.c 
	gidlmodule.h 
	gidlnode.c 
	gidlnode.h 
	gidlparser.c 
	gidlparser.h 
	girepository.h 
	gmetadata.c 
	gmetadata.h
)

add_library(gidl ${GIDL_SOURCES})
target_link_libraries(gidl
	${GLIB_LIBRARIES}
	${GMODULE_LIBRARIES}
)

set(GI_PARSER_C ${CMAKE_CURRENT_BINARY_DIR}/scannerparser.c)
set(GI_LEXER_C ${CMAKE_CURRENT_BINARY_DIR}/scannerlexer.c)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
bison_target(
	scannerparser
	scannerparser.y
	${GI_PARSER_C}
	COMPILE_FLAGS -d
)
flex_target(
	scannerlexer
	scannerlexer.l
	${GI_LEXER_C}
)
add_flex_bison_dependency(scannerlexer scannerparser)

set(GI_SOURCES
	grealpath.h 
	gidlwriter.c 
	gidlwriter.h 
	scanner.c 
	scanner.h 
	${GI_PARSER_C}
	${GI_LEXER_C}
)

add_executable(gen-introspect ${GI_SOURCES})
target_link_libraries(gen-introspect
	${GLIB_LIBRARIES}
	${GMODULE_LIBRARIES}
	${GOBJECT_LIBRARIES}
	gidl
)

set(GIDL_VAPI_DIR ${CMAKE_CURRENT_SOURCE_DIR} PARENT_SCOPE)
set(GIDL_VAPI ${GIDL_VAPI_DIR}/gidl.vapi)