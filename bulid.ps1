$GAPHD_DIR = $(Get-Location)

if (!(Test-Path $GAPHD_DIR/thirdparty)) {
	mkdir -p $GAPHD_DIR/thirdparty
}
if (!(Test-Path $GAPHD_DIR/release)) {
	mkdir -p $GAPHD_DIR/release
}
if (!(Test-Path $GAPHD_DIR/templibinstall)) {
	mkdir -p $GAPHD_DIR/templibinstall
}
if (!(Test-Path $GAPHD_DIR/build)) {
	mkdir -p $GAPHD_DIR/build
}


# 下载Julia
Set-Location $GAPHD_DIR/release
if (!(Test-Path ./julia*)) {
	Invoke-WebRequest https://mirror.tuna.tsinghua.edu.cn/julia-releases/bin/winnt/x64/1.10/julia-1.10.2-win64.zip -OutFile ./julia.zip
	Expand-Archive julia.zip -DestinationPath julia_
	Move-Item -Path julia_/julia* -Destination .
	Remove-Item julia.zip
	Remove-Item julia_
}

# 编译jluna
Set-Location $GAPHD_DIR/thirdparty
if (!(Test-Path ./jluna)) {
	git clone https://github.com/Clemapfel/jluna.git
}

if (!(Test-Path $GAPHD_DIR/templibinstall/jluna/bin/jluna.dll)) {
	Set-Location jluna
	cmake  -DCMAKE_INSTALL_PREFIX="$GAPHD_DIR/templibinstall/jluna" -B ./build
	cmake --build ./build --config Debug
	cmake --install ./build --config Debug
	Copy-Item $GAPHD_DIR/templibinstall/jluna/bin/jluna.dll $GAPHD_DIR/release/bin/jluna.dll
}

# 编译gAPHD
Set-Location $GAPHD_DIR
cmake -DCMAKE_INSTALL_PREFIX="$GAPHD_DIR/release" -B ./build
cmake --build ./build --config Debug
cmake --install ./build --config Debug

# 设置Qt依赖
if (!(Test-Path $GAPHD_DIR/release/bin/gaphd.exe)) {
	windeployqt --qmldir $GAPHD_DIR/src/gui $GAPHD_DIR/release/bin/gaphd.exe
}
