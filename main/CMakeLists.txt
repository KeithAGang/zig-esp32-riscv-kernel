# 1. Register the component
idf_component_register(SRCS "" INCLUDE_DIRS ".")

if(NOT IDF_BUILD_PREPARING)
  set(ZIG_LIB "${CMAKE_CURRENT_SOURCE_DIR}/../zig-out/lib/libzig_app.a")
  set(PATHS_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/../generate_paths.py")

  # 2. Chain the Python script and Zig build together!
  # By putting them in the same custom_command, they run during the BUILD phase
  # when compile_commands.json is guaranteed to exist.
  add_custom_command(
        OUTPUT "${ZIG_LIB}"
        COMMAND ${PYTHON} "${PATHS_SCRIPT}"
        COMMAND zig build
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/.."
        VERBATIM
    )

  add_custom_target(zig_app_target DEPENDS "${ZIG_LIB}")

  target_link_libraries(${COMPONENT_LIB} INTERFACE "${ZIG_LIB}")
  add_dependencies(${COMPONENT_LIB} zig_app_target)

  # Force the linker to look for app_main in the Zig static lib
  target_link_options(${COMPONENT_LIB} INTERFACE "-u" "app_main")
endif()
