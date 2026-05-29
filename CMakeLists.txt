cmake_minimum_required(VERSION 3.24)

project(GeoControls VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

option(GEOCONTROLS_INSTALL_SDK "Install GeoControls CMake package and headers" OFF)
option(GEOCONTROLS_BUILD_DEMO "Build GeoControls GuiDemo example" ${PROJECT_IS_TOP_LEVEL})

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Svg)
qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(Controls)

if(GEOCONTROLS_BUILD_DEMO)
    add_subdirectory(GuiDemo)
endif()

if(GEOCONTROLS_INSTALL_SDK)
    install(
        TARGETS ${GEOCONTROLS_EXPORT_TARGETS}
        EXPORT GeoControlsTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        OBJECTS DESTINATION ${CMAKE_INSTALL_LIBDIR}/objects
    )

    install(
        EXPORT GeoControlsTargets
        FILE GeoControlsTargets.cmake
        NAMESPACE GeoControls::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GeoControls
    )

    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/GeoControlsConfigVersion.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/GeoControlsConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/GeoControlsConfig.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GeoControls
    )

    install(
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/GeoControlsConfig.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/GeoControlsConfigVersion.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GeoControls
    )
endif()
