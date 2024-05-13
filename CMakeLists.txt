cmake_minimum_required(VERSION 3.21.1)

project(gAPHD LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

if (MSVC)
	file(GLOB_RECURSE QML_FILES "src/gui/**/*.qml")

	foreach(QML_FILE ${QML_FILES})
    # 获取文件的路径
    get_filename_component(QML_PATH "${QML_FILE}" PATH)
    # 将文件路径转换为相对于qml文件夹的路径
    file(RELATIVE_PATH QML_GROUP "${CMAKE_CURRENT_SOURCE_DIR}/src" "${QML_PATH}")
    # 将路径中的斜杠转换为反斜杠，这是Visual Studio中的筛选器格式
    string(REPLACE "/" "\\" QML_GROUP "${QML_GROUP}")
	string(REPLACE "gui" "Gui" QML_GROUP "${QML_GROUP}")
    # 为文件设置筛选器
    source_group("${QML_GROUP}" FILES "${QML_FILE}")
	endforeach()
endif()

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml Quick Widgets Sql Charts Network Xml)

if (Qt6_VERSION VERSION_GREATER_EQUAL 6.3)
    qt_standard_project_setup()
endif()

file(GLOB_RECURSE SOURCES src/*.cpp include/*.h)

qt_add_resources(RESOURCES src/gui/qml.qrc)

qt_add_executable(gAPHD 
	${RESOURCES}
	${SOURCES}
)

find_library(jluna REQUIRED 
    NAMES jluna
    PATHS templibinstall/jluna/lib
)

file(GLOB JULIA_LIBS ./release/julia-1.10.2/lib/*.a)

target_include_directories(gAPHD PRIVATE 
	release/julia-1.10.2/include/julia
	templibinstall/jluna/include/jluna
)
target_link_libraries(gAPHD PRIVATE 
    ${jluna} 
    ${JULIA_LIBS}
)

target_link_libraries(gAPHD PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Widgets
    Qt6::Sql
    Qt6::Charts
	Qt6::Network
	Qt6::Xml
)

target_compile_features(gAPHD PRIVATE cxx_std_20)

install(TARGETS gAPHD
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
