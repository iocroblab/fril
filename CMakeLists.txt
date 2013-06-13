#########################################################################
# CMakeLists.txt file for building FRIL with CMake                      #
#                                                                       #
# Copyright (c) 2012-2013 Leopold Palomo-Avellaneda <leo@alaxarxa.net>  #
#                                                                       #
# This file is free software: you can redistribute it and/or modify     #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

cmake_minimum_required (VERSION 2.6)

project(FRIL)

# FRIL version. Defined here but not exported to header files, because it's already defined there 
set( FRIL_VERSION 0.0.1 )
string( REGEX MATCHALL "[0-9]+" FRIL_VERSIONS ${FRIL_VERSION} )
LIST( GET FRIL_VERSIONS 0 FRIL_VERSION_MAJOR)
LIST( GET FRIL_VERSIONS 1 FRIL_VERSION_MINOR)
LIST( GET FRIL_VERSIONS 2 FRIL_VERSION_PATCH)
# Some example programs use "libpthread"
# http://stackoverflow.com/questions/1620918/cmake-and-libpthread
find_package(Threads REQUIRED)


########################
# Defining the sources
########################
add_definitions(-DHAVE_SOCKLEN_T)


########################
# Defining the sources
########################

include_directories(${CMAKE_SOURCE_DIR}/include)

# FRIL header files
set(FRIL_HDRS include/Console.h
              include/DataLogging.h
              include/Doxygen.h
              include/FastResearchInterface.h
              include/FastResearchInterfaceTest.h
              include/friComm.h
              include/friudp.h
              include/InitializationFileEntry.h
              include/LinuxAbstraction.h
              include/LWRBaseControllerInterface.h
              include/LWRCartImpedanceController.h
              include/LWRJointImpedanceController.h
              include/LWRJointPositionController.h
              include/LWRJointTorqueController.h
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
              include/WindowsAbstraction.h
)

# FRIL source files (without examples)
set(FRIL_SRC
              src/FastResearchInterfaceLibrary/Console.cpp
              src/FastResearchInterfaceLibrary/DataLogging.cpp
              src/FastResearchInterfaceLibrary/FastResearchInterface.cpp
              src/FastResearchInterfaceLibrary/friudp.cpp
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
              src/FastResearchInterfaceLibrary/WaitForTicks.cpp
)
set(FRIL_TEST_SRC
        src/FastResearchInterfaceTest
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
if(WIN32)
  set(FRIL_TEST_SRC ${FRIL_SRC}
      src/WindowsAbstraction/WindowsAbstraction.cpp)
endif()
if(UNIX)
  add_definitions(-D__LINUX__)
  set(FRIL_TEST_SRC ${FRIL_SRC}
      src/LinuxAbstraction/LinuxAbstraction.cpp)
endif()
# src/MACOSAbstraction/MACOSAbstraction.cpp
# src/QNXAbstraction/QNXAbstraction.cpp


add_library(fril_static STATIC ${FRIL_SRC} )
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

# Create dynamic library (.so) with all basic FRIL functions
add_library(fril_dynamic SHARED ${FRIL_SRC})
set_target_properties( fril_dynamic PROPERTIES
  DEFINE_SYMBOL "FRIL_DLL_EXPORT"
  SOVERSION "${FRIL_VERSION_MAJOR}.${FRIL_VERSION_MINOR}.${FRIL_VERSION_PATCH}"
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
# 
# if(ENABLE_TESTS)
# #ebox eepromtool red_test simple_test slaveinfo firm_update
#   if(WIN32)
#     add_executable(ebox test/win32/ebox/ebox.c)
#     target_link_libraries(ebox soem_dynamic ${CMAKE_THREAD_LIBS_INIT})
#  
#     add_executable(simple_test test/win32/simple_test/simple_test.c)
#     target_link_libraries(simple_test soem_dynamic)
#  
#     add_executable(eepromtool test/win32/eepromtool/eepromtool.c)
#     target_link_libraries(eepromtool soem_dynamic)
#  
#     add_executable(slaveinfo test/win32/slaveinfo/slaveinfo.c)
#     target_link_libraries(slaveinfo soem_dynamic)
#  
#     add_executable(red_test test/win32/red_test/red_test.c)
#     target_link_libraries(red_test soem_dynamic ${CMAKE_THREAD_LIBS_INIT})
#     
#     add_executable(firm_update test/win32/firm_update/firm_update.c)
#     target_link_libraries(firm_update soem_dynamic ${CMAKE_THREAD_LIBS_INIT})
#   endif()
# 
#   if(UNIX)
#     add_executable(ebox test/linux/ebox/ebox.c)
#     target_link_libraries(ebox soem_dynamic ${CMAKE_THREAD_LIBS_INIT})
#  
#     add_executable(simple_test test/linux/simple_test/simple_test.c)
#     target_link_libraries(simple_test soem_dynamic ${CMAKE_THREAD_LIBS_INIT})
#  
#     add_executable(eepromtool test/linux/eepromtool/eepromtool.c)
#     target_link_libraries(eepromtool soem_dynamic)
#  
#     add_executable(slaveinfo test/linux/slaveinfo/slaveinfo.c)
#     target_link_libraries(slaveinfo soem_dynamic)
#  
#     add_executable(red_test test/linux/red_test/red_test.c)
#     target_link_libraries(red_test soem_dynamic ${CMAKE_THREAD_LIBS_INIT})
#     
#     add_executable(firm_update test/linux/firm_update/firm_update.c)
#     target_link_libraries(firm_update soem_dynamic ${CMAKE_THREAD_LIBS_INIT})
#   endif()
# 
# endif(ENABLE_TESTS)
# 
# INSTALL(TARGETS ebox eepromtool red_test simple_test slaveinfo firm_update DESTINATION bin)
# INSTALL(TARGETS soem_static soem_dynamic DESTINATION lib)
# 
# # Just ones headers
# INSTALL(FILES ${FRIL_HDRS} ${OSAL_H} ${OSHW_HDRS} DESTINATION include/soem)
# 
#  
# # # Build example executables
# # # NOTE: The executables are statically linked (soem functions embedded)
# # # If you wish to link them dynamically with libsoem.so, 
# # # then change "soem_static" to "soem" in link commands below
# # 
# # 
# if(ENABLE_RTNET)
#    message(STATUS "Compiler RTNet flags: " ${RT_COMPILE_FLAGS})
#    message(STATUS "Linker RTNet flags: " ${RT_LINK_FLAGS})
# 
#   # Create static library (.a) with all basic FRIL functions
#   include_directories(${RTNET_INCLUDE_DIR})
# 
#   add_library(soem_static_rt STATIC ${FRIL_SRC} ${OSHW_SRC} ${OSAL_SRC})
#   set_target_properties(soem_static_rt 
#     PROPERTIES DEFINE_SYMBOL "FRIL_DLL_EXPORT"
#     OUTPUT_NAME soemrt 
#   # Set accumulated compilation flags: (.so and .a)
#     COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#     LINK_FLAGS "${RT_LINK_FLAGS}"
#     VERSION "${FRIL_VERSION}"
#     CLEAN_DIRECT_OUTPUT 1)
# 
#   # Create dynamic library (.so) with all basic FRIL functions
#   add_library(soem_dynamic_rt SHARED ${FRIL_SRC} ${OSHW_SRC} ${OSAL_SRC})
#   set_target_properties( soem_dynamic_rt PROPERTIES
#     DEFINE_SYMBOL "FRIL_DLL_EXPORT"
#     SOVERSION "${FRIL_VERSION_MAJOR}.${FRIL_VERSION_MINOR}.${FRIL_VERSION_PATCH}"
#     VERSION "${FRIL_VERSION}"
#     OUTPUT_NAME soemrt
#   # Set accumulated compilation flags: (.so and .a)
#     COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#     LINK_FLAGS "${RT_LINK_FLAGS}"
#     INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
#     CLEAN_DIRECT_OUTPUT 1)
#     IF (UNIX AND NOT APPLE)
#     SET_TARGET_PROPERTIES( soem_dynamic_rt PROPERTIES
#       COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#       LINK_FLAGS "${RT_LINK_FLAGS} ${LINK_FLAGS} -Wl,-zdefs")
#     ENDIF ()
# 
#   # Build example executables
#   # NOTE: The executables are statically linked (soem functions embedded)
#   # If you wish to link them dynamically with libsoem.so, 
#   # then change "soem_static" to "soem" in link commands below
# 
#   if(ENABLE_TESTS)
#     add_executable(ebox_rt test/linux/ebox/ebox.c)
#     target_link_libraries(ebox_rt libsoemrt.a ${CMAKE_SHARED_LINKER_FLAGS_RTNET} ${CMAKE_THREAD_LIBS_INIT})
#     set_target_properties(ebox_rt PROPERTIES
#       COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#       LINK_FLAGS "${RT_LINK_FLAGS}")
#     
#     add_executable(simple_test_rt test/linux/simple_test/simple_test.c)
#     target_link_libraries(simple_test_rt libsoemrt.a ${CMAKE_EXE_LINKER_FLAGS_RTNET} ${CMAKE_THREAD_LIBS_INIT})
#  
#     add_executable(eepromtool_rt test/linux/eepromtool/eepromtool.c)
#     target_link_libraries(eepromtool_rt libsoemrt.a ${CMAKE_EXE_LINKER_FLAGS_RTNET})
#  
#     add_executable(slaveinfo_rt test/linux/slaveinfo/slaveinfo.c)
#     target_link_libraries(slaveinfo_rt libsoemrt.a ${CMAKE_EXE_LINKER_FLAGS_RTNET} )
#     set_target_properties(slaveinfo_rt PROPERTIES
#       COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#       LINK_FLAGS "${RT_LINK_FLAGS}")
#     
#     add_executable(red_test_rt test/linux/red_test/red_test.c)
#     target_link_libraries(red_test_rt libsoemrt.a ${CMAKE_EXE_LINKER_FLAGS_RTNET}  ${CMAKE_THREAD_LIBS_INIT})
#     set_target_properties(red_test_rt PROPERTIES
#       COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#       LINK_FLAGS "${RT_LINK_FLAGS}")
#     
#     
#     add_executable(firm_update_rt test/linux/firm_update/firm_update.c)
#     target_link_libraries(firm_update_rt libsoemrt.a ${CMAKE_THREAD_LIBS_INIT})
#     set_target_properties(firm_update_rt PROPERTIES
#       COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#       LINK_FLAGS "${RT_LINK_FLAGS}")
#   endif()
# 
#  if(ENABLE_TESTS_DYNAMIC)
#     add_executable(ebox_rt_d test/linux/ebox/ebox.c)
#     target_link_libraries(ebox_rt_d soem_dynamic_rt ${CMAKE_EXE_LINKER_FLAGS_RTNET} ${CMAKE_THREAD_LIBS_INIT})
#  
#     add_executable(simple_test_rt_d test/linux/simple_test/simple_test.c)
#     target_link_libraries(simple_test_rt_d soem_dynamic_rt ${CMAKE_EXE_LINKER_FLAGS_RTNET}  ${CMAKE_THREAD_LIBS_INIT})
#  
#     add_executable(eepromtool_rt_d test/linux/eepromtool/eepromtool.c)
#     target_link_libraries(eepromtool_rt_d soem_dynamic_rt ${CMAKE_EXE_LINKER_FLAGS_RTNET})
#  
#     add_executable(slaveinfo_rt_d test/linux/slaveinfo/slaveinfo.c)
#     target_link_libraries(slaveinfo_rt_d soem_dynamic_rt ${CMAKE_EXE_LINKER_FLAGS_RTNET})
#     set_target_properties(slaveinfo_rt_d PROPERTIES
#     COMPILE_FLAGS "${RT_COMPILE_FLAGS}"
#       LINK_FLAGS "${RT_LINK_FLAGS}")
# 
#     add_executable(red_test_rt_d test/linux/red_test/red_test.c)
#     target_link_libraries(red_test_rt_d soem_dynamic_rt ${CMAKE_EXE_LINKER_FLAGS_RTNET} ${CMAKE_THREAD_LIBS_INIT})
#     
#     add_executable(firm_update_rt_d test/linux/firm_update/firm_update.c)
#     target_link_libraries(firm_update_rt_d soem_dynamic_rt ${CMAKE_EXE_LINKER_FLAGS_RTNET}  ${CMAKE_THREAD_LIBS_INIT} )
#   endif()
# 
#   # Install files into system directories
#   INSTALL(TARGETS ebox_rt eepromtool_rt red_test_rt simple_test_rt slaveinfo_rt firm_update_rt 
#                   ebox_rt_d eepromtool_rt_d red_test_rt_d simple_test_rt_d slaveinfo_rt_d firm_update_rt_d
#           DESTINATION bin)
#   INSTALL(TARGETS soem_static_rt soem_dynamic_rt DESTINATION lib)
#   #INSTALL(FILES ${FRIL_HDRS} DESTINATION include/soem)
# endif()
# 
