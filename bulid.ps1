$GAPHD_DIR = $(Get-Location)

mkdir -p $GAPHD_DIR/thirdparty
mkdir -p $GAPHD_DIR/release
mkdir -p $GAPHD_DIR/build

## Navigate to release directory
#Set-Location $GAPHD_DIR/release

# Download Julia binary
#Invoke-WebRequest https://mirror.tuna.tsinghua.edu.cn/julia-releases/bin/winnt/x64/1.10/julia-1.10.2-win64.zip -o julia-1.10.2-win64.zip
#Expand-Archive julia-1.10.2-win64.zip
#Remove-Item julia-1.10.2-win64.zip

# Placeholder for juliabackend sysimg creation - 
#Set-Location $GAPHD_DIR/juliabackend
#git clone git@github.com:ai4energy/Ai4EExample.git
#julia --project=./compile compile/create_img.jl
#mkdir -p $GAPHD_DIR/release/bin/
#Move-Item ai4eexample-20240412.dll $GAPHD_DIR/release/bin/

# Clone and build jluna
Set-Location $GAPHD_DIR/thirdparty
git clone https://github.com/Clemapfel/jluna.git
Set-Location jluna
#sed -i '141a \    OUTPUT_NAME "foo"' CMakeLists.txt
#Set-Location build

# Configure jluna with Julia binary path
cmake -DJULIA_BINDIR="$GAPHD_DIR/release/julia-1.10.2-win64/julia-1.10.2/bin" -DCMAKE_INSTALL_PREFIX="$GAPHD_DIR/templibinstall" -B ./build

cmake --build ./build --config Debug
cmake --install ./build --config Debug

Copy-Item $GAPHD_DIR/templibinstall/bin/jluna.dll $GAPHD_DIR/release/bin

# Configure and build the gaphd main program

Set-Location $GAPHD_DIR
cmake -DCMAKE_INSTALL_PREFIX="$GAPHD_DIR/release" -B .
cmake --build . --config Debug
cmake --install . --config Debug

# Deploy the Qt application
#windeployqt --qmldir $GAPHD_DIR/src/gui $GAPHD_DIR/release/bin/gaphd.exe
