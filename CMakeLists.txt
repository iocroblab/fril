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

cmake_minimum_required (VERSION 2.6)

project(FRIL)

# FRIL version. Defined here but not exported to header files, because it's already defined there 
set( FRIL_VERSION 1.2 )
string( REGEX MATCHALL "[0-9]+" FRIL_VERSIONS ${FRIL_VERSION} )
LIST( GET FRIL_VERSIONS 0 FRIL_VERSION_MAJOR)
LIST( GET FRIL_VERSIONS 1 FRIL_VERSION_MINOR)
# Some example programs use "libpthread"
# http://stackoverflow.com/questions/1620918/cmake-and-libpthread

find_package(Threads REQUIRED)
# TODO, the Windows version should use the pthread library provided.

########################
# Defining the sources
########################

include_directories(${CMAKE_SOURCE_DIR}/include)

# FRIL header files
set(FRIL_HDRS  include/Console.h
               include/DataLogging.h
               include/Doxygen.h
               include/FastResearchInterface.h
               include/FastResearchInterfaceTest.h
               include/FRICommunication.h
               include/InitializationFileEntry.h
               include/LinuxAbstraction.h
               include/LWRBaseControllerInterface.h
               include/LWRCartImpedanceController.h
               include/LWRJointImpedanceController.h
               include/LWRJointPositionController.h
               include/MACOSAbstraction.h
               include/OSAbstraction.h
               include/QNXAbstraction.h
               include/TypeIRMLDecision.h
               include/TypeIRML.h
               include/TypeIRMLInputParameters.h
               include/TypeIRMLMath.h
               include/TypeIRMLOutputParameters.h
               include/TypeIRMLPolynomial.h
               include/TypeIRMLProfiles.h
               include/TypeIRMLVector.h
               include/UDPSocket.h
               include/WindowsAbstraction.h)

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
set(FRIL_TYPEIRML_SRC
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
endif()

# Check if it's an Apple OS
IF (APPLE)
# Check if it's OS X or another MacOS (that's got to be pretty unlikely)
   STRING (REGEX MATCH "Darwin" OS_OSX ${CMAKE_SYSTEM_NAME})
   IF (NOT OS_OSX)
      set(FRIL_TEST_SRC ${FRIL_SRC}
            src/MACOSAbstraction/MACOSAbstraction.cpp)
      message (STATUS "Detected a MacOS Platform")
   ENDIF (NOT OS_OSX)
ENDIF (APPLE)
# QNX
IF (QNXNTO)
   set(FRIL_TEST_SRC ${FRIL_SRC}
           src/QNXAbstraction/QNXAbstraction.cpp)
   message (STATUS "Detected a QNX Platform")
ENDIF (QNXNTO)

# CMake does not distinguish Linux from other Unices.
STRING (REGEX MATCH "Linux" OS_LINUX ${CMAKE_SYSTEM_NAME})
if(OS_LINUX)
   add_definitions(-D__LINUX__ -DHAVE_SOCKLEN_T)
   set(FRIL_SRC ${FRIL_SRC}
      src/LinuxAbstraction/LinuxAbstraction.cpp)
   message (STATUS "Detected a Linux Platform")
endif(OS_LINUX)


add_library(fril_static STATIC ${FRIL_SRC} )
target_link_libraries(fril_static ${CMAKE_THREAD_LIBS_INIT})
set_target_properties(fril_static 
  PROPERTIES DEFINE_SYMBOL "FRIL_DLL_EXPORT"
  OUTPUT_NAME fril
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
  VERSION "${FRIL_VERSION}"
  CLEAN_DIRECT_OUTPUT 1)
  if(UNIX AND NOT APPLE)
    target_link_libraries(fril_static rt ${CMAKE_THREAD_LIBS_INIT})
  endif()

# Defaul install
    install(TARGETS fril_static DESTINATION lib)

# Create dynamic library (.so) with all basic FRIL functions
add_library(fril_dynamic SHARED ${FRIL_SRC})
target_link_libraries(fril_dynamic ${CMAKE_THREAD_LIBS_INIT})
set_target_properties( fril_dynamic PROPERTIES
  DEFINE_SYMBOL "FRIL_DLL_EXPORT"
  SOVERSION "${FRIL_VERSION_MAJOR}.${FRIL_VERSION_MINOR}"
  VERSION "${FRIL_VERSION}"
  OUTPUT_NAME fril
# Set accumulated compilation flags: (.so and .a)
  COMPILE_FLAGS "${CMAKE_CXX_FLAGS_ADD}"
  LINK_FLAGS "${CMAKE_LD_FLAGS_ADD}"
  INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
  CLEAN_DIRECT_OUTPUT 1)
  IF (UNIX AND NOT APPLE)
   SET_TARGET_PROPERTIES( fril_dynamic PROPERTIES
     LINK_FLAGS "-Wl,-zdefs")
   target_link_libraries(fril_dynamic rt ${CMAKE_THREAD_LIBS_INIT})
  endif ()

 # Defaul install
    install(TARGETS fril_dynamic DESTINATION lib)
  
  ########################
  # Test and examples
  ########################
  OPTION(ENABLE_TESTS "Compilation of test and example programs" ON)
  if(ENABLE_TESTS)
    add_library(fril_irml_dynamic STATIC ${FRIL_TYPEIRML_SRC})
    add_library(fril_test_dynamic STATIC ${FRIL_TEST_SRC})
   
    add_executable(fastResearchInterfaceTest src/FastResearchInterfaceTest/FastResearchInterfaceTest.cpp)
    target_link_libraries(fastResearchInterfaceTest fril_test_dynamic fril_dynamic fril_irml_dynamic)
    
    add_executable(LWRCartImpedanceControlExample src/LWRGettingStartedExamples/LWRCartImpedanceControlExample.cpp)
    target_link_libraries(LWRCartImpedanceControlExample fril_test_dynamic fril_dynamic fril_irml_dynamic)
    
    add_executable(LWRJointImpedanceControlExample src/LWRGettingStartedExamples/LWRJointImpedanceControlExample.cpp)
    target_link_libraries(LWRJointImpedanceControlExample fril_test_dynamic fril_dynamic fril_irml_dynamic)
    
    add_executable(LWRJointPositionControlExample src/LWRGettingStartedExamples/LWRJointPositionControlExample.cpp)
    target_link_libraries(LWRJointPositionControlExample fril_test_dynamic fril_dynamic fril_irml_dynamic)
    
    add_executable(LWRLoggingExample src/LWRGettingStartedExamples/LWRLoggingExample.cpp)
    target_link_libraries(LWRLoggingExample fril_test_dynamic fril_dynamic fril_irml_dynamic)    
  endif(ENABLE_TESTS)

 ########################
  # Install
  ########################


    # Headers install
    install(FILES ${FRIL_HDRS}  DESTINATION include/fril)

# 
