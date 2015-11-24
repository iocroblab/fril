#########################################################################
# CMakeLists.txt file for building FRIL with CMake                      #
#                                                                       #
# Copyright (c) 2012-2015 Leopold Palomo-Avellaneda <leopold.palomo@upc.edu>  #
#                                                                       #
#  Licensed under the Apache License, Version 2.0 (the "License");      #
#  you may not use this file except in compliance with the License.     #
#  You may obtain a copy of the License at\n
# 
#  http://www.apache.org/licenses/LICENSE-2.0\n
# 
#  Unless required by applicable law or agreed to in writing, software\n
#  distributed under the License is distributed on an "AS IS" BASIS,\n  
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#  implied.\n
#  See the License for the specific language governing permissions and\n
#  limitations under the License.\n
#########################################################################

cmake_minimum_required (VERSION 2.8.8)

project(FRIL)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# FRIL version. Defined here but not exported to header files, because it's already defined there 
set( FRIL_VERSION 1.2 )
string( REGEX MATCHALL "[0-9]+" FRIL_VERSIONS ${FRIL_VERSION} )
LIST( GET FRIL_VERSIONS 0 FRIL_VERSION_MAJOR)
LIST( GET FRIL_VERSIONS 1 FRIL_VERSION_MINOR)

set( TYPEIRML_VERSION 1.2 )
string( REGEX MATCHALL "[0-9]+" TYPEIRML_VERSIONS ${TYPEIRML_VERSION} )
LIST( GET TYPEIRML_VERSIONS 0 TYPEIRML_VERSION_MAJOR)
LIST( GET TYPEIRML_VERSIONS 1 TYPEIRML_VERSION_MINOR)

set(FRIL_DIRNAME_lib ${CMAKE_INSTALL_LIBDIR})
set(FRIL_DIRNAME_include "${CMAKE_INSTALL_PREFIX}/include/fril")

set(TYPEIRML_DIRNAME_lib ${CMAKE_INSTALL_LIBDIR})
set(TYPEIRML_DIRNAME_include "${CMAKE_INSTALL_PREFIX}/include/RML")

# Some example programs use "libpthread"
# http://stackoverflow.com/questions/1620918/cmake-and-libpthread
find_package(Threads REQUIRED)
# TODO, the Windows version should use the pthread library provided.


include_directories(${CMAKE_SOURCE_DIR}/include)

option(ENABLE_RTNET "Enable RTnet over Xenomai." ON)

if(ENABLE_RTNET)
  #common commands for building c++ executables and libraries
  find_path(RTNET_INCLUDE_DIR NAMES rtnet.h PATH_SUFFIXES rtnet/include)
  if(NOT RTNET_INCLUDE_DIR)
    set(ENABLE_RTNET OFF)
  endif()

  if(RTNET_INCLUDE_DIR)
   message("Found RTNET: ${RTNET_INCLUDE_DIR}")
   # try Xenomai
   # find Xenomai (version 2.x) it should be upgrade to 3.x
   include(FindPkgConfig)

   #dependencies native
   pkg_check_modules(XENO_NATIVE REQUIRED libxenomai_native)
   message("Found xenomai native includes : ${XENO_NATIVE_INCLUDE_DIRS}" )
   message("--> with CFLAGS : ${XENO_NATIVE_CFLAGS}" )
   message("Found xenomai native libs : ${XENO_NATIVE_LIBRARIES}" )
   message("--> with LDFLAGS : ${XENO_NATIVE_LDFLAGS}" )

   # posix
   pkg_check_modules(XENO_POSIX REQUIRED libxenomai_posix)
   message("Found xenomai posix includes : ${XENO_POSIX_INCLUDE_DIRS}" )
   message("--> with CFLAGS : ${XENO_POSIX_CFLAGS}" )
   message("Found xenomai posix libs : ${XENO_POSIX_LIBRARIES}" )
   message("--> with LDFLAGS : ${XENO_POSIX_LDFLAGS}" )

   # RTDM
   pkg_check_modules(XENO_RTDM REQUIRED libxenomai_rtdm)
   message("Found xenomai rtdm includes : ${XENO_RTDM_INCLUDE_DIRS}" )
   message("--> with CFLAGS : ${XENO_RTDM_CFLAGS}" )
   message("Found xenomai rtdm libs : ${XENO_RTDM_LIBRARIES}" )
   message("--> with LDFLAGS : ${XENO_RTDM_LDFLAGS}" )

   # setting some flags for the lib
   # ########################################################
   # Arranging some list ...
   string (REPLACE ";" " " FRIL_CFLAGS_RTNET "${XENO_RTDM_CFLAGS}")
   set(FRIL_CFLAGS_RTNET "-DRTNET ${FRIL_CFLAGS_RTNET}")

   string (REPLACE ";" " " CMAKE_LINKER_FLAGS_RTNET "${XENO_RTDM_LDFLAGS}")
   set(CMAKE_LINKER_FLAGS_RTNET "-lnative ${CMAKE_LINKER_FLAGS_RTNET}" ${XENO_POSIX_LDFLAGS})    
        
   message(STATUS "Compiler RTNET Flags for the library: " ${FRIL_CFLAGS_RTNET})
   message(STATUS "Linker RTNET flags for the library: " ${CMAKE_LINKER_FLAGS_RTNET})

   # setting some flags for the examples
   # ########################################################
   set(FRIL_CFLAGS_POSIX "-DRTNET ${XENO_POSIX_CFLAGS}")
   set(CMAKE_EXE_LINKER_FLAGS_RTNET "-lnative ${XENO_POSIX_LDFLAGS}")
    
   message(STATUS "Compiler RTNET POSIX flags for the examples: " ${FRIL_CFLAGS_POSIX})
   message(STATUS "Linker RTNET POSIX flags for the examples: " ${CMAKE_EXE_LINKER_FLAGS_RTNET})
  endif()
endif()  


########################
# Defining the sources
########################

# FRIL header files
set(FRIL_HDRS  include/Console.h
               include/DataLogging.h
               include/Doxygen.h
               include/FastResearchInterface.h
               include/FastResearchInterfaceTest.h
               include/FRICommunication.h
               include/InitializationFileEntry.h
               include/LWRBaseControllerInterface.h
               include/LWRCartImpedanceController.h
               include/LWRJointImpedanceController.h
               include/LWRJointPositionController.h
               include/OSAbstraction.h
               include/UDPSocket.h)

set(TYPEIRML_HDRS include/TypeIRMLDecision.h
               include/TypeIRML.h
               include/TypeIRMLInputParameters.h
               include/TypeIRMLMath.h
               include/TypeIRMLOutputParameters.h
               include/TypeIRMLPolynomial.h
               include/TypeIRMLProfiles.h
               include/TypeIRMLVector.h)

# FRIL source files (without examples)
set(FRIL_SRC
              src/FastResearchInterfaceLibrary/Console.cpp
              src/FastResearchInterfaceLibrary/DataLogging.cpp
              src/FastResearchInterfaceLibrary/FastResearchInterface.cpp
              src/FastResearchInterfaceLibrary/GetCompleteRobotStateAndInformation.cpp
              src/FastResearchInterfaceLibrary/GetRobotControlData.cpp
              src/FastResearchInterfaceLibrary/GetRobotStatusData.cpp
              src/FastResearchInterfaceLibrary/GetUDPCommunicationData.cpp
              src/FastResearchInterfaceLibrary/InitializationFileEntry.cpp
              src/FastResearchInterfaceLibrary/KRCCommunicationThreadMain.cpp
              src/FastResearchInterfaceLibrary/LoggingMethods.cpp
              src/FastResearchInterfaceLibrary/ReadInitFile.cpp
              src/FastResearchInterfaceLibrary/SetControlScheme.cpp
              src/FastResearchInterfaceLibrary/SetRobotControlData.cpp
              src/FastResearchInterfaceLibrary/SetRobotStatusData.cpp
              src/FastResearchInterfaceLibrary/StartRobot.cpp
              src/FastResearchInterfaceLibrary/StopRobot.cpp
              src/FastResearchInterfaceLibrary/TimerThreadMain.cpp
              src/FastResearchInterfaceLibrary/UDPSocket.cpp
              src/FastResearchInterfaceLibrary/WaitForTicks.cpp
)
set(FRIL_TEST_SRC
        src/FastResearchInterfaceTest/FastResearchInterfaceTest.cpp
        src/FastResearchInterfaceTest/MoveToCandle.cpp
        src/FastResearchInterfaceTest/RunTrajectorySimple.cpp)
set(FRIL_STARTED_EXAMPLES
        src/LWRGettingStartedExamples/LWRCartImpedanceControlExample.cpp
        src/LWRGettingStartedExamples/LWRJointImpedanceControlExample.cpp
        src/LWRGettingStartedExamples/LWRJointPositionControlExample.cpp
        src/LWRGettingStartedExamples/LWRLoggingExample.cpp)
set(TYPEIRML_SRC
        src/TypeIRML/TypeIRML.cpp
        src/TypeIRML/TypeIRMLDecision.cpp
        src/TypeIRML/TypeIRMLMath.cpp
        src/TypeIRML/TypeIRMLPolynomial.cpp
        src/TypeIRML/TypeIRMLProfiles.cpp)


#### Adding some files depending on OS
if(WIN32)
   set(FRIL_TEST_SRC ${FRIL_SRC}
      src/WindowsAbstraction/WindowsAbstraction.cpp)
   message (STATUS "Detected a Windows Platform")
   set(FRIL_HDRS ${FRIL_HDRS} include/WindowsAbstraction.h)
endif()

# Check if it's an Apple OS
IF (APPLE)
# Check if it's OS X or another MacOS (that's got to be pretty unlikely)
   STRING (REGEX MATCH "Darwin" OS_OSX ${CMAKE_SYSTEM_NAME})
   IF (NOT OS_OSX)
      set(FRIL_TEST_SRC ${FRIL_SRC}
            src/MACOSAbstraction/MACOSAbstraction.cpp)
      message (STATUS "Detected a MacOS Platform")
      set(FRIL_HDRS ${FRIL_HDRS} include/MACOSAbstraction.h)
   ENDIF (NOT OS_OSX)
ENDIF (APPLE)
# QNX
IF (QNXNTO)
   set(FRIL_TEST_SRC ${FRIL_SRC}
           src/QNXAbstraction/QNXAbstraction.cpp)
   set(FRIL_HDRS ${FRIL_HDRS} include/QNXAbstraction.h)
   message (STATUS "Detected a QNX Platform")
ENDIF (QNXNTO)

# CMake does not distinguish Linux from other Unices.
STRING (REGEX MATCH "Linux" OS_LINUX ${CMAKE_SYSTEM_NAME})
if(OS_LINUX)
   add_definitions(-D__LINUX__ -DHAVE_SOCKLEN_T)
   set(FRIL_SRC ${FRIL_SRC}
      src/LinuxAbstraction/LinuxAbstraction.cpp)
   set(FRIL_HDRS ${FRIL_HDRS} include/LinuxAbstraction.h)
   message (STATUS "Detected a Linux Platform")
endif(OS_LINUX)

set(FRIL_TARGETS fril_static 
		 fril_dynamic)
set(TYPEIRML_TARGETS TypeIRML_static
		 TypeIRML_dynamic)

add_library(fril_static STATIC ${FRIL_SRC} )
target_link_libraries(fril_static ${CMAKE_THREAD_LIBS_INIT})
set_target_properties(fril_static 
  PROPERTIES DEFINE_SYMBOL "FRIL_DLL_EXPORT"
  OUTPUT_NAME FastResearchInterfaceLibrary
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
  VERSION "${FRIL_VERSION}"
  CLEAN_DIRECT_OUTPUT 1)
  if(UNIX AND NOT APPLE)
    target_link_libraries(fril_static rt ${CMAKE_THREAD_LIBS_INIT})
  endif()

# Create dynamic library (.so) with all basic FRIL functions
add_library(fril_dynamic SHARED ${FRIL_SRC})
target_link_libraries(fril_dynamic ${CMAKE_THREAD_LIBS_INIT})
set_target_properties( fril_dynamic PROPERTIES
  DEFINE_SYMBOL "FRIL_DLL_EXPORT"
  VERSION "${FRIL_VERSION_MAJOR}.${FRIL_VERSION_MINOR}"
  SOVERSION "${FRIL_VERSION_MAJOR}"
  OUTPUT_NAME FastResearchInterfaceLibrary
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
  INSTALL_NAME_DIR "${CMAKE_INSTALL_LIBDIR}"
  CLEAN_DIRECT_OUTPUT 1)
  IF (UNIX AND NOT APPLE)
   SET_TARGET_PROPERTIES( fril_dynamic PROPERTIES
     LINK_FLAGS "-Wl,-zdefs ${CMAKE_LD_FLAGS_ADD}")
   target_link_libraries(fril_dynamic rt ${CMAKE_THREAD_LIBS_INIT})
  endif ()

add_library(TypeIRML_static STATIC ${TYPEIRML_SRC})
set_target_properties(TypeIRML_static PROPERTIES
  OUTPUT_NAME TypeIRML
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  VERSION "${FRIL_VERSION}"
  CLEAN_DIRECT_OUTPUT 1)

# Create dynamic library (.so) with all basic functions
add_library(TypeIRML_dynamic SHARED ${TYPEIRML_SRC})
set_target_properties( TypeIRML_dynamic PROPERTIES
  VERSION "${FRIL_VERSION_MAJOR}.${FRIL_VERSION_MINOR}"
  SOVERSION "${FRIL_VERSION_MAJOR}"
  OUTPUT_NAME TypeIRML
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
  INSTALL_NAME_DIR "${CMAKE_INSTALL_LIBDIR}"
  CLEAN_DIRECT_OUTPUT 1)

  ########################
  # Test and examples
  ########################
  OPTION(ENABLE_TESTS "Compilation of test and example programs" ON)
  if(ENABLE_TESTS)
  
    add_executable(fastResearchInterfaceTest ${FRIL_TEST_SRC})
    target_link_libraries(fastResearchInterfaceTest fril_dynamic TypeIRML_dynamic)
    
    add_executable(LWRCartImpedanceControlExample src/LWRGettingStartedExamples/LWRCartImpedanceControlExample.cpp)
    target_link_libraries(LWRCartImpedanceControlExample fril_dynamic TypeIRML_dynamic)
    
    add_executable(LWRJointImpedanceControlExample src/LWRGettingStartedExamples/LWRJointImpedanceControlExample.cpp)
    target_link_libraries(LWRJointImpedanceControlExample fril_dynamic TypeIRML_dynamic)
    
    add_executable(LWRJointPositionControlExample src/LWRGettingStartedExamples/LWRJointPositionControlExample.cpp)
    target_link_libraries(LWRJointPositionControlExample fril_dynamic TypeIRML_dynamic )
    
    add_executable(LWRLoggingExample src/LWRGettingStartedExamples/LWRLoggingExample.cpp)
    target_link_libraries(LWRLoggingExample fril_dynamic TypeIRML_dynamic)    
   
    install(TARGETS fastResearchInterfaceTest LWRCartImpedanceControlExample
		    LWRJointImpedanceControlExample LWRJointPositionControlExample
		    LWRLoggingExample
   	    RUNTIME DESTINATION bin)
  endif(ENABLE_TESTS)

 

# RTNET part
###############################################################################
if(ENABLE_RTNET)
  set (FRIL_TARGETS ${FRIL_TARGETS} fril_static_rt fril_dynamic_rt)
  add_library(fril_static_rt STATIC ${FRIL_SRC} )
  target_link_libraries(fril_static_rt ${CMAKE_LINKER_FLAGS_RTNET})
  set_target_properties(fril_static_rt PROPERTIES 
  DEFINE_SYMBOL "FRIL_DLL_EXPORT"
  OUTPUT_NAME FastResearchInterfaceLibrary_rt 
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
  VERSION "${FRIL_VERSION}"
  CLEAN_DIRECT_OUTPUT 1)

# Create dynamic library (.so) with all basic FRIL functions
  add_library(fril_dynamic_rt SHARED ${FRIL_SRC})
  target_link_libraries(fril_dynamic_rt ${CMAKE_LINKER_FLAGS_RTNET})
  set_target_properties( fril_dynamic_rt PROPERTIES 
  DEFINE_SYMBOL "FRIL_DLL_EXPORT"
  VERSION "${FRIL_VERSION_MAJOR}.${FRIL_VERSION_MINOR}"
  SOVERSION "${FRIL_VERSION_MAJOR}"
  OUTPUT_NAME FastResearchInterfaceLibrary_rt
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
  INSTALL_NAME_DIR "${CMAKE_INSTALL_LIBDIR}"
  CLEAN_DIRECT_OUTPUT 1)

  ########################
  # Test and examples
  ########################
  OPTION(ENABLE_TESTS_RT "Compilation of test and example RT versions programs" ON)
  if(ENABLE_TESTS_RT)
    add_executable(fastResearchInterfaceTest_rt ${FRIL_TEST_SRC})
    target_link_libraries(fastResearchInterfaceTest_rt fril_dynamic_rt TypeIRML_dynamic)     

    add_executable(LWRCartImpedanceControlExample_rt src/LWRGettingStartedExamples/LWRCartImpedanceControlExample.cpp)
    target_link_libraries(LWRCartImpedanceControlExample_rt fril_dynamic_rt TypeIRML_dynamic)
    
    add_executable(LWRJointImpedanceControlExample_rt src/LWRGettingStartedExamples/LWRJointImpedanceControlExample.cpp)
    target_link_libraries(LWRJointImpedanceControlExample_rt fril_dynamic_rt TypeIRML_dynamic)
    
    add_executable(LWRJointPositionControlExample_rt src/LWRGettingStartedExamples/LWRJointPositionControlExample.cpp)
    target_link_libraries(LWRJointPositionControlExample_rt fril_dynamic_rt TypeIRML_dynamic)
    
    add_executable(LWRLoggingExample_rt src/LWRGettingStartedExamples/LWRLoggingExample.cpp)
    target_link_libraries(LWRLoggingExample_rt fril_dynamic_rt TypeIRML_dynamic)    
   
    install(TARGETS fastResearchInterfaceTest_rt LWRCartImpedanceControlExample_rt
		    LWRJointImpedanceControlExample_rt LWRJointPositionControlExample_rt
		    LWRLoggingExample_rt 
   	    RUNTIME DESTINATION bin)
  endif(ENABLE_TESTS_RT)
endif(ENABLE_RTNET)   


########################
# Install libs
########################

# Headers install
install(FILES ${FRIL_HDRS} DESTINATION include/fril)
install(FILES ${TYPEIRML_HDRS} DESTINATION include/RML)

install(TARGETS ${FRIL_TARGETS} EXPORT FRILExports
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include/fril)

install(TARGETS ${TYPEIRML_TARGETS} EXPORT TYPEIRMLExports
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include/RML)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/frilConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/frilConfig.cmake"
  INSTALL_DESTINATION  ${FRIL_DIRNAME_lib}/cmake/fril
  PATH_VARS 
   FRIL_DIRNAME_lib
   FRIL_DIRNAME_include)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/TypeIRMLConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/TypeIRMLConfig.cmake"
  INSTALL_DESTINATION  ${TYPEIRML_DIRNAME_lib}/cmake/TypeIRML
  PATH_VARS 
   TYPEIRML_DIRNAME_lib
   TYPEIRML_DIRNAME_include)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/frilConfigVersion.cmake"
  VERSION ${FRIL_VERSION}
  COMPATIBILITY AnyNewerVersion)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/TypeIRMLConfigVersion.cmake"
  VERSION ${TYPEIRML_VERSION}
  COMPATIBILITY AnyNewerVersion)

install( EXPORT FRILExports
         DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/fril)

install( EXPORT TYPEIRMLExports
         DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/TypeIRML)
   
install( FILES ${CMAKE_CURRENT_BINARY_DIR}/frilConfig.cmake
       ${CMAKE_CURRENT_BINARY_DIR}/frilConfigVersion.cmake
       DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/fril)
   
install( FILES ${CMAKE_CURRENT_BINARY_DIR}/TypeIRMLConfig.cmake
       ${CMAKE_CURRENT_BINARY_DIR}/TypeIRMLConfigVersion.cmake
       DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/TypeIRML)

