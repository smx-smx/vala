set(CCODE_SOURCES
	valaccodeassignment.vala
	valaccodebinaryexpression.vala
	valaccodeblock.vala
	valaccodebreakstatement.vala
	valaccodecasestatement.vala
	valaccodecastexpression.vala
	valaccodecommaexpression.vala
	valaccodecomment.vala
	valaccodeconditionalexpression.vala
	valaccodeconstant.vala
	valaccodecontinuestatement.vala
	valaccodedeclaration.vala
	valaccodedeclarator.vala
	valaccodedostatement.vala
	valaccodeemptystatement.vala
	valaccodeenum.vala
	valaccodeenumvalue.vala
	valaccodeexpression.vala
	valaccodeexpressionstatement.vala
	valaccodefile.vala
	valaccodeforstatement.vala
	valaccodefragment.vala
	valaccodefunction.vala
	valaccodefunctioncall.vala
	valaccodefunctiondeclarator.vala
	valaccodeggnucsection.vala
	valaccodegotostatement.vala
	valaccodeidentifier.vala
	valaccodeifstatement.vala
	valaccodeincludedirective.vala
	valaccodeinitializerlist.vala
	valaccodeinvalidexpression.vala
	valaccodelabel.vala
	valaccodelinedirective.vala
	valaccodeifsection.vala
	valaccodemacroreplacement.vala
	valaccodememberaccess.vala
	valaccodemodifiers.vala
	valaccodenewline.vala
	valaccodenode.vala
	valaccodeoncesection.vala
	valaccodeparameter.vala
	valaccodeparenthesizedexpression.vala
	valaccodereturnstatement.vala
	valaccodestatement.vala
	valaccodestruct.vala
	valaccodeswitchstatement.vala
	valaccodetypedefinition.vala
	valaccodeunaryexpression.vala
	valaccodevariabledeclarator.vala
	valaccodewhilestatement.vala
	valaccodewriter.vala
	valaccodeelementaccess.vala
)

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