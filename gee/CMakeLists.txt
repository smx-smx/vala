set(GEE_SOURCES
	arraylist.vala
	collection.vala
	hashmap.vala
	hashset.vala
	iterable.vala
	mapiterator.vala
	iterator.vala
	list.vala
	map.vala
	set.vala
	timsort.vala
)

set(MODULE_NAME gee)

set(GEE_VAPI_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
set(GEE_VAPI ${GEE_VAPI_DIR}/${MODULE_NAME}.vapi PARENT_SCOPE)

vala_precompile(VALA_C
	${GEE_SOURCES}
LIBRARY
	${MODULE_NAME}
PACKAGES
    gobject-2.0
OPTIONS
	--use-header
GENERATE_VAPI
	${GEE_VAPI}
GENERATE_HEADER
    valagee
)

add_library(${MODULE_NAME} ${VALA_C})
target_link_libraries(${MODULE_NAME}
	${GLIB_LIBRARIES}
	${GOBJECT_LIBRARIES}
)