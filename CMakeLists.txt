cmake_minimum_required(VERSION 3.21.1)

project(gAPHD LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Core Gui Qml Quick Widgets Sql Charts Network Xml)

if (Qt6_VERSION VERSION_GREATER_EQUAL 6.3)
    qt_standard_project_setup()
endif()

file(GLOB_RECURSE SOURCES src/*.cpp ./include/*.h)

qt_add_resources(RESOURCES src/gui/qml.qrc)

qt_add_executable(gAPHD 
	${RESOURCES}

	${SOURCES}
)

find_library(OTHERLIB_LIBRARY NAMES jluna PATHS ./thirdparty/jluna/build/Debug)

# 现在，你可以将otherlib的头文件目录添加到你的项目中
target_include_directories(gAPHD PRIVATE 
	./thirdparty/jluna
	./release/julia-1.10.2-win64/julia-1.10.2/include/julia
)

file(GLOB JULIA_LIBS ./release/julia-1.10.2-win64/julia-1.10.2/lib/*.a)

# 然后链接到你的应用程序或库
target_link_libraries(gAPHD PRIVATE 
	${JULIA_LIBS}
	${MYLIB}
	${OTHERLIB_LIBRARY}
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
