option(
  USE_PCH
  "Use precompiled headers for STL"
  ON
  )

if (USE_PCH)
  set(PCH_PATH "${CMAKE_BINARY_DIR}/Precompiled.h")
  configure_file(
    ${CMAKE_SOURCE_DIR}/Precompiled.h
    ${CMAKE_BINARY_DIR}/Precompiled.h
    )

  # The compiler flags need to be turned into a CMake list
  if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    string(REPLACE " " ";" PCH_COMPILE_FLAGS
      "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}"
      )
  elseif("${CMAKE_BUILD_TYPE}" STREQUAL "None")
    string(REPLACE " " ";" PCH_COMPILE_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
  elseif("${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    string(REPLACE " " ";" PCH_COMPILE_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
  elseif("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    string(REPLACE " " ";" PCH_COMPILE_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
  else()
    string(REPLACE " " ";" PCH_COMPILE_FLAGS
      "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}"
      )
  endif()

  add_custom_command(
    OUTPUT ${PCH_PATH}.pch
    COMMAND ${CMAKE_CXX_COMPILER}
    ARGS
    ${PCH_COMPILE_FLAGS}
    -x c++-header
    -I${CMAKE_SOURCE_DIR}/src
    -I${CMAKE_SOURCE_DIR}/json
    ${PCH_PATH}
    -o ${PCH_PATH}.pch
    DEPENDS
    ${PCH_PATH}
    )

  add_custom_target(
    pch
    DEPENDS
    ${PCH_PATH}
    ${PCH_PATH}.pch
    )

  # Prepend the compiler-dependent flags needed to use precompiled headers
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_CXX_FLAGS "-include ${PCH_PATH}.pch ${CMAKE_CXX_FLAGS}")
  elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "-include-pch ${PCH_PATH}.pch ${CMAKE_CXX_FLAGS}")
  else()
    message(
      STATUS "Precompiled headers have not been configured for"
      " the compiler: ${CMAKE_CXX_COMPILER_ID}"
      )
  endif()

  # Override the default add_library and add_executable function provided
  # by CMake so that it adds the precompiled header as a dependency to
  # all of them.
  #
  # In addition to the library/executable depending on the precompiled header,
  # all source files (technically the objects generated from them) must also
  # depend on the precompiled header.
  function(add_library TARGET_NAME)
    _add_library(${TARGET_NAME} ${ARGN})
    add_dependencies(${TARGET_NAME} pch)
    set_source_files_properties(
      ${ARGN}
      OBJECT_DEPENDS "${PCH_PATH};${PCH_PATH}.pch"
      )
  endfunction()

  function(add_executable TARGET_NAME)
    _add_executable(${TARGET_NAME} ${ARGN})
    add_dependencies(${TARGET_NAME} pch)
    set_source_files_properties(
      ${ARGN}
      OBJECT_DEPENDS "${PCH_PATH};${PCH_PATH}.pch"
      )
  endfunction()

endif (USE_PCH)
