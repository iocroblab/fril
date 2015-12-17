###############################################################################
#
# CMake script for finding the Xenomai Libraries and skins
#
# Copyright 2015 Leopold Palomo-Avellaneda <leopold.palomo@upc.edu>
# Copyright 2015 Institute of Industrial and Control Engineering (IOC)
#                Universitat Politecnica de Catalunya
#                BarcelonaTech
# Redistribution and use is allowed according to the terms of the 3-clause BSD
# license.
#
#
# Input variables:
# 
# - ${Xenomai_ROOT_DIR} (optional): Used as a hint to find the Xenomai root dir
# - $ENV{XENOMAI_ROOT_DIR} (optional): Used as a hint to find the Xenomai root dir
#
# Cache variables (not intended to be used in CMakeLists.txt files)
# Input variables:
# 
# - ${Xenomai_ROOT_DIR} (optional): Used as a hint to find the Xenomai root dir
# - $ENV{XENOMAI_ROOT_DIR} (optional): Used as a hint to find the Xenomai root dir
#
# Output Variables:
#
# - Xenomai_FOUND: Boolean that indicates if the package was found. Default is Native
# - Xenomai_SKINS: List of the available skins. The availabe skins are: 
#   NATIVE POSIX PSOS RTDM UITRON VRTX VXWORKS
# - Xenomai_*_FOUND variables below for individual skins.
# - Xenomai_VERSION: major.minor.patch Xenomai version string
# - Xenomai_XENO_CONFIG: Path to xeno-config program
# 
# For each available skin, theses Var are set:
#   - Xenomai_${SKIN}_FOUND: Boolean that indicates if the skin was found
#   - Xenomai_${SKIN}_DEFINITIONS
#   - Xenomai_${SKIN}_INCLUDE_DIRS
#   - Xenomai_${SKIN}_LIBRARY_DIRS
#   - Xenomai_${SKIN}_LIBRARIES
#   - Xenomai_${SKIN}_LDFLAGS
#
# Specific var for compatibility with Johns Hopkins University (JHU) FindXenomai
#
# - Individual library variables:
#   - Xenomai_LIBRARY_XENOMAI
#   - Xenomai_LIBRARY_NATIVE
#   - Xenomai_LIBRARY_PTHREAD_RT
#   - Xenomai_LIBRARY_RTDM
#   - Xenomai_LIBRARY_RTDK ( this will be empty, deprecated after Xenomai 2.6.0)
#
#
#
# Example usage:
#
# find_package(Xenomai 2.6.4 POSIX REQUIRED)
# message(STATUS "Xenomai found with theses skins: ${Xenomai_SKINS}")
# # You have some sources xeno-example ${XENO_EXAMPLE_SRC}
# 
# include_directories(${Xenomai_POSIX_INCLUDE_DIR})
# add_executable(demo_xeno ${XENO_EXAMPLE_SRC})
# target_link_libraries(demo_xeno ${Xenomai_POSIX_LIBRARY_DIRS} ${Xenomai_POSIX_LIBRARIES})
# set_target_properties(demo_xeno PROPERTIES
#                  LINK_FLAGS ${Xenomai_POSIX_LDFLAGS})
# target_compile_definitions(demo_xeno PUBLIC ${Xenomai_POSIX_DEFINITIONS})


###############################################################################
# Returns the definitions and includes from a cflags output
# 
# _list cflags var
# _includes return var with the Includes
# _definitions return var with the Definitions 
function(PARSE_CFLAGS _list _includes _definitions)

   separate_arguments(${_list})
   foreach(_item ${${_list}})
      if("${_item}" MATCHES "^-I")
         string(SUBSTRING ${_item} 2 -1 _item_t)
         set(_includes_t ${_includes_t} ${_item_t})
      else("${_item}" MATCHES "^-I")
         set(_definitions_t ${_definitions_t} ${_item})
      endif("${_item}" MATCHES "^-I")
   endforeach(_item)
   
   string (REPLACE ";" " " _definitions_k "${_definitions_t}")
   
   set(${_includes} ${_includes_t} PARENT_SCOPE )
   set(${_definitions} ${_definitions_k} PARENT_SCOPE)

   #message(STATUS "Calling Macro ${${_list}} and returning ${_includes_k} and ${_definitions_k}")
endfunction(PARSE_CFLAGS)
###############################################################################


###############################################################################
# Retrieve information from a ldflags output
# 
# _list ldflags var
# _libraries return var with the libraries
# _ldflags return var with the ldflags value
# _libdir return var with the libdir value
function(PARSE_LDFLAGS _list _libraries _ldflags _libdir)

   separate_arguments(${_list})
   foreach(_item ${${_list}})
      if("${_item}" MATCHES "^-l")
         string(SUBSTRING ${_item} 2 -1 _item_t)   
         set(_libraries_t ${_libraries_t} ${_item_t})
      elseif("${_item}" MATCHES "^-L")
         set(_libdir_t ${_libdir_t} ${_item})
      else("${_item}" MATCHES "^-L")
         set(_ldflags_t ${_ldflags_t} ${_item})
      endif("${_item}" MATCHES "^-l")
   endforeach(_item ${${_list}})
   
   string (REPLACE ";" " " _ldflags_k "${_ldflags_t}")
   string (REPLACE ";" " " _libdir_k "${_libdir_t}")
   
   set(${_libraries} ${_libraries_t} PARENT_SCOPE )
   set(${_ldflags} ${_ldflags_k} PARENT_SCOPE)
   set(${_libdir} ${_libdir_k} PARENT_SCOPE)

   #message(STATUS "Calling Macro ${${_list}} and returning ${_libraries_k} ${_ldflags_k} ${_libdir_k}")
endfunction(PARSE_LDFLAGS)
###############################################################################

include(FindPackageHandleStandardArgs)

if( Xenomai_FIND_COMPONENTS )
  # if components specified in find_package(), make sure each of those pieces were found
  set(_XENOMAI_FOUND_REQUIRED_VARS )
  foreach( component ${Xenomai_FIND_COMPONENTS} )
    string( TOUPPER ${component} _COMPONENT )
    set(_XENOMAI_FOUND_REQUIRED_VARS ${_XENOMAI_FOUND_REQUIRED_VARS} Xenomai_${_COMPONENT}_INCLUDE_DIRS  Xenomai_${_COMPONENT}_LIBRARIES)
  endforeach()
else()
  # if no components specified, we'll make a default set of required variables to say Qt is found
  set(_XENOMAI_FOUND_REQUIRED_VARS Xenomai_XENO_CONFIG Xenomai_VERSION Xenomai_NATIVE_INCLUDE_DIRS Xenomai_NATIVE_LIBRARIES)
endif()

# Get hint from environment variable (if any)
if(NOT $ENV{XENOMAI_ROOT_DIR} STREQUAL "")
  set(XENOMAI_ROOT_DIR $ENV{XENOMAI_ROOT_DIR} CACHE PATH "Xenomai base directory location (optional, used for nonstandard installation paths)" FORCE)
  mark_as_advanced(XENOMAI_ROOT_DIR)
endif()

# set the search paths
set( Xenomai_SEARCH_PATH /usr/local /usr $ENV{XENOMAI_ROOT_DIR} ${Xenomai_ROOT_DIR})

# Find xeno-config
find_program(Xenomai_XENO_CONFIG NAMES xeno-config  PATHS ${Xenomai_SEARCH_PATH}/bin NO_DEFAULT_PATH)

if(Xenomai_XENO_CONFIG)
   set(Xenomai_FOUND ${Xenomai_XENO_CONFIG})
   execute_process(COMMAND ${Xenomai_XENO_CONFIG} --version OUTPUT_VARIABLE Xenomai_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE )
   message(STATUS "xeno-config is found. Xenomai should be ok and version found is ${Xenomai_VERSION}")

   set(Xenomai_SKINS)
   set(SKINS native posix psos rtdm uitron vrtx vxworks)
   foreach(_skin ${SKINS})
      #message(STATUS "Processing skin ${_skin} ........")
      string(TOUPPER ${_skin} SKINU)
      
      execute_process(COMMAND ${Xenomai_XENO_CONFIG}  --skin "${_skin}" --cflags OUTPUT_VARIABLE XENO_${SKINU}_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
      PARSE_CFLAGS("XENO_${SKINU}_CFLAGS" "Xenomai_${SKINU}_INCLUDE_DIRS" "Xenomai_${SKINU}_DEFINITIONS")
      #message(STATUS "Xenomai_${SKINU}_INCLUDE_DIRS = ${Xenomai_${SKINU}_INCLUDE_DIRS}")
      #message(STATUS "Xenomai_${SKINU}_DEFINITIONS = ${Xenomai_${SKINU}_DEFINITIONS}")

      execute_process(COMMAND ${Xenomai_XENO_CONFIG}  --skin ${_skin} --ldflags OUTPUT_VARIABLE XENO_${SKINU}_LDFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
      PARSE_LDFLAGS("XENO_${SKINU}_LDFLAGS" "Xenomai_${SKINU}_LIBRARIES" "Xenomai_${SKINU}_LDFLAGS" "Xenomai_${SKINU}_LIBRARY_DIRS")
      #message(STATUS "Xenomai_${SKINU}_LIBRARIES = ${Xenomai_${SKINU}_LIBRARIES}")
      #message(STATUS "Xenomai_${SKINU}_DIRS = ${Xenomai_${SKINU}_LIBRARY_DIRS}")
      #message(STATUS "Xenomai_${SKINU}_LDFLAGS = ${Xenomai_${SKINU}_LDFLAGS}")

      if(Xenomai_${SKINU}_LIBRARIES AND Xenomai_${SKINU}_INCLUDE_DIRS)
         set(Xenomai_${SKINU}_FOUND TRUE)
         set(Xenomai_SKINS ${Xenomai_SKINS} ${_skin})
         #message(STATUS "Xenomai ${_skin} skin found")
         set(Xenomai_${SKINU}_FOUND ${Xenomai_${SKINU}_FOUND} CACHE STRING "Xenomai ${SKINU} Found" FORCE)
         set(Xenomai_${SKINU}_DEFINITIONS ${Xenomai_${SKINU}_DEFINITIONS} CACHE STRING "Xenomai ${SKINU} skin definitions" FORCE)
         set(Xenomai_${SKINU}_INCLUDE_DIRS ${Xenomai_${SKINU}_INCLUDE_DIRS} CACHE STRING "Xenomai ${SKINU} include directories" FORCE)
         set(Xenomai_${SKINU}_LIBRARY_DIRS ${Xenomai_${SKINU}_LIBRARY_DIRS} CACHE STRING "Xenomai ${SKINU} library directories" FORCE)
         set(Xenomai_${SKINU}_LIBRARIES ${Xenomai_${SKINU}_LIBRARIES}  CACHE STRING "Xenomai ${SKINU} libraries" FORCE)
         set(Xenomai_${SKINU}_LDFLAGS ${Xenomai_${SKINU}_LDFLAGS} CACHE STRING "Xenomai ${SKINU} ldflags" FORCE)
      endif()
   endforeach(_skin ${SKINS})
     
   find_library( Xenomai_LIBRARY_NATIVE     native     ${Xenomai_ROOT_DIR}/lib )
   find_library( Xenomai_LIBRARY_XENOMAI    xenomai    ${Xenomai_ROOT_DIR}/lib )
   find_library( Xenomai_LIBRARY_PTHREAD_RT pthread_rt ${Xenomai_ROOT_DIR}/lib )
   find_library( Xenomai_LIBRARY_RTDM       rtdm       ${Xenomai_ROOT_DIR}/lib )

   # In 2.6.0 RTDK was merged into the main xenomai library
   if(Xenomai_VERSION VERSION_GREATER 2.6.0)
      set(Xenomai_LIBRARY_RTDK_FOUND ${Xenomai_LIBRARY_XENOMAI_FOUND})
      set(Xenomai_LIBRARY_RTDK ${Xenomai_LIBRARY_XENOMAI})
   else()
      find_library( Xenomai_LIBRARY_RTDK rtdk ${Xenomai_ROOT_DIR}/lib )
   endif()
 
   find_package_handle_standard_args(Xenomai REQUIRED_VARS ${_XENOMAI_FOUND_REQUIRED_VARS} 
                                  VERSION_VAR Xenomai_VERSION
                                  HANDLE_COMPONENTS )
else(Xenomai_XENO_CONFIG)
   message(FATAL_ERROR "This program needs xeno-config")
endif()

