#!/bin/bash

# FFMPEG Installer For CentOS 7 [CMM]

# Scripted by Brijendra Sial @ Bullten Web Hosting Solutions [https://www.bullten.com]

RED='\033[01;31m'
RESET='\033[0m'
GREEN='\033[01;32m'
YELLOW='\e[93m'
WHITE='\e[97m'
BLINK='\e[5m'

set -e
#set -x

CUDA_REPO="10.2.89-1"
NASM_VER="2.14.02"
LAME_VER="3.100"
LIBOGG_VER="1.3.4"
LIBVORBIS_VER="1.3.6"
LIBTHEORA_VER="1.1.1"
LIBASS_VER="0.14.0"
DEST_DIR="/usr/local/ffmpeg"
BIND_DIR="/usr/local/bin"
CUDA_DIR="/usr/local/cuda"
CHAN_DIR="/root/ffmpeg-sources"
TMP_DIR="/home/tmp"

VERSION_CHECK=`rpm -E %{rhel}`

if [ "${VERSION_CHECK}" = '7' ]; then
		echo " "
		echo -e $GREEN"CentOS 7 Found. Starting Installation"$RESET
		echo " "
else
		echo " "
		echo -e $RED"Only CentOS 7 is Supported. Exiting Installation"$RESET
		echo " "
		exit
fi

echo " "
echo -e $GREEN"Updating System"$RESET
echo " "
sleep 2

yum update -y

echo " "
echo -e $GREEN"System Updation Completed"$RESET
echo " "
sleep 2

echo " "
echo -e $GREEN"Installing EPEL Repository"$RESET
echo " "
sleep 2

if  rpm -q epel-release > /dev/null ; then
        echo " "
        echo -e $YELLOW"EPEL Repository Installation Found. Skipping It"$RESET
        echo " "
		sleep 2
else
        echo " "
        echo -e $RED"EPEL Repository Installation Not Found. Installing It"$RESET
        echo " "
		yum install epel-release -y
		echo " "
		echo -e $YELLOW"EPEL Repository Installation Completed"$RESET
		echo " "
		sleep 2
fi

echo " "
echo -e $GREEN"Installing Required Dependencies"$RESET
echo " "
sleep 2


yum install autoconf automake unzip bzip2 bzip2-devel wget cmake cmake3 freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel numactl numactl-devel doxygen fribidi-devel libaom-devel libaom opencv opencv-devel libtheora-devel libvorbis-devel libva libva-devel graphviz fontconfig fontconfig-devel libdrm libdrm-devel -y

echo " "
echo -e $YELLOW"Required Dependencies Installed"$RESET
echo " "
sleep 2

echo " "
echo -e $GREEN"Removing NASM if Installed"$RESET
echo " "
sleep 2

if  rpm -q nasm > /dev/null ; then
        echo " "
        echo -e $YELLOW"NASM Installation Found. Removing it"$RESET
        echo " "
		yum remove nasm -y
		echo " "
		echo -e $YELLOW"Removal of NASM Completed"$RESET
		echo " "
		sleep 2
else
        echo " "
        echo -e $RED"NASM Installation Not Found"$RESET
        echo " "
		sleep 2
fi

cat > /etc/ld.so.conf.d/ffmpeg.conf <<"EOF"
/usr/local/ffmpeg/lib
/usr/lib
EOF

rm -rf ${CHAN_DIR}
mkdir -p ${CHAN_DIR}

function CUDA_INSTALL
{
echo " "
echo -e $GREEN"Starting CUDA Installation"$RESET
echo " "
sleep 2

rpm -ivh https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-${CUDA_REPO}.x86_64.rpm
yum install cuda -y

echo " "
echo -e $YELLOW"CUDA Installation Completed"$RESET
echo " "
sleep 2
}

function NVCODEC_INSTALL
{
echo " "
echo -e $GREEN"Starting NVCODEC Installation"$RESET
echo " "
sleep 2

#Install NVCODEC
cd ${CHAN_DIR}
git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers
make
make install PREFIX="$DEST_DIR"

echo " "
echo -e $YELLOW"NVCODEC Installation Completed"$RESET
echo " "
sleep 2
}

function NASM_INSTALL
{
echo " "
echo -e $GREEN"Starting NASM Installation"$RESET
echo " "
sleep 2

#Install NASM
cd ${CHAN_DIR}
curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VER}/nasm-${NASM_VER}.tar.bz2
tar xjvf nasm-${NASM_VER}.tar.bz2
cd nasm-${NASM_VER}
./autogen.sh
./configure --prefix="${DEST_DIR}" --bindir="${BIND_DIR}"
make
make install
make distclean

echo " "
echo -e $YELLOW"NASM Installation Completed"$RESET
echo " "
sleep 2
}

function YASM_INSTALL
{
echo " "
echo -e $GREEN"Starting YASM Installation"$RESET
echo " "
sleep 2

#Install YASM
cd ${CHAN_DIR}
git clone --depth 1 git://github.com/yasm/yasm.git
cd yasm
autoreconf -fiv
./configure --prefix="${DEST_DIR}" --bindir="${BIND_DIR}"
make
make install
make distclean

echo " "
echo -e $YELLOW"YASM Installation Completed"$RESET
echo " "
sleep 2
}

function X264_INSTALL
{
echo " "
echo -e $GREEN"Starting X264 Installation"$RESET
echo " "
sleep 2

#Install X264
cd ${CHAN_DIR}
git clone https://code.videolan.org/videolan/x264.git
cd x264
./configure --prefix="${DEST_DIR}" --bindir="${BIND_DIR}" --enable-static
make
make install
make distclean

echo " "
echo -e $YELLOW"X264 Installation Completed"$RESET
echo " "
sleep 2
}

function X265_INSTALL
{
echo " "
echo -e $GREEN"Starting X265 Installation"$RESET
echo " "
sleep 2

#Install X265
cd ${CHAN_DIR}
hg clone https://bitbucket.org/multicoreware/x265
cd x265/build/linux
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${DEST_DIR}" -DENABLE_SHARED:bool=off ../../source
make
make install
rm -rf /usr/local/bin/x265
ln -s /usr/local/ffmpeg/bin/x265 /usr/local/bin/x265

echo " "
echo -e $YELLOW"X265 Installation Completed"$RESET
echo " "
sleep 2
}

function AOM_INSTALL
{
echo " "
echo -e $GREEN"Starting AOM Installation"$RESET
echo " "
sleep 2

#Install AOM
cd ${CHAN_DIR}
git clone https://aomedia.googlesource.com/aom
mkdir -p aom/aom_build
cd aom/aom_build
cmake3 -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${DEST_DIR}" -DENABLE_NASM=on ../../aom
make
make install

rm -rf /usr/local/bin/aomdec
rm -rf /usr/local/bin/aomenc

ln -s /usr/local/ffmpeg/bin/aomdec /usr/local/bin/aomdec
ln -s /usr/local/ffmpeg/bin/aomenc /usr/local/bin/aomenc

echo " "
echo -e $YELLOW"AOM Installation Completed"$RESET
echo " "
sleep 2
}

function FDKACC_INSTALL
{
echo " "
echo -e $GREEN"Starting FDK-ACC Installation"$RESET
echo " "
sleep 2

#Install FDK-ACC
cd ${CHAN_DIR}
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="${DEST_DIR}" --disable-shared
make
make install
make distclean

echo " "
echo -e $YELLOW"FDK-ACC Installation Completed"$RESET
echo " "
sleep 2
}

function MP3LAME_INSTALL
{
echo " "
echo -e $GREEN"Starting MP3LAME Installation"$RESET
echo " "
sleep 2

#Install MP3LAME
cd ${CHAN_DIR}
curl -L -O http://downloads.sourceforge.net/project/lame/lame/${LAME_VER}/lame-${LAME_VER}.tar.gz
tar xzvf lame-${LAME_VER}.tar.gz
cd lame-${LAME_VER}
./configure --prefix="${DEST_DIR}" --bindir="${BIND_DIR}" --disable-shared --enable-nasm
make
make install
make distclean

echo " "
echo -e $YELLOW"MP3LAME Installation Completed"$RESET
echo " "
sleep 2
}

function OPUS_INSTALL
{
echo " "
echo -e $GREEN"Starting OPUS Installation"$RESET
echo " "
sleep 2

#Install OPUS
cd ${CHAN_DIR}
git clone git://git.opus-codec.org/opus.git
cd opus
autoreconf -fiv
./configure --prefix="${DEST_DIR}" --disable-shared
make
make install
make distclean

echo " "
echo -e $YELLOW"OPUS Installation Completed"$RESET
echo " "
sleep 2
}

function LIBOGG_INSTALL
{
echo " "
echo -e $GREEN"Starting LIBOGG Installation"$RESET
echo " "
sleep 2

#Install LIBOGG
cd ${CHAN_DIR}
curl -L -O https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-${LIBOGG_VER}.tar.gz
tar xzvf libogg-${LIBOGG_VER}.tar.gz
cd libogg-${LIBOGG_VER}
./configure --prefix="${DEST_DIR}" --disable-shared
make
make install
make distclean

echo " "
echo -e $YELLOW"LIBOGG Installation Completed"$RESET
echo " "
sleep 2
}

function LIBVORBIS_INSTALL
{
echo " "
echo -e $GREEN"Starting LIBVORBIS Installation"$RESET
echo " "
sleep 2

#Install LIBVORBIS
cd ${CHAN_DIR}
curl -L -O https://ftp.osuosl.org/pub/xiph/releases/vorbis/libvorbis-${LIBVORBIS_VER}.zip
unzip libvorbis-${LIBVORBIS_VER}.zip
cd libvorbis-${LIBVORBIS_VER}
./configure --prefix="${DEST_DIR}" --with-ogg="${DEST_DIR}" --disable-shared
make
make install
make distclean

echo " "
echo -e $YELLOW"LIBVORBIS Installation Completed"$RESET
echo " "
sleep 2
}

function LIBVPX_INSTALL
{
echo " "
echo -e $GREEN"Starting LIBVPX Installation"$RESET
echo " "
sleep 2

#Install LIBVPX
cd ${CHAN_DIR}
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="${DEST_DIR}" --disable-examples --disable-dependency-tracking --disable-unit-tests
make
make install
make distclean

echo " "
echo -e $YELLOW"LIBVPX Installation Completed"$RESET
echo " "
sleep 2
}

function LIBTHEORA_INSTALL
{
echo " "
echo -e $GREEN"Starting LIBTHEORA Installation"$RESET
echo " "
sleep 2

#Install LIBTHEORA
cd ${CHAN_DIR}
curl -L -O https://ftp.osuosl.org/pub/xiph/releases/theora/libtheora-${LIBTHEORA_VER}.zip
unzip libtheora-${LIBTHEORA_VER}.zip
cd libtheora-${LIBTHEORA_VER}
./configure --prefix="${DEST_DIR}" --with-ogg="${DEST_DIR}" --disable-examples --disable-shared --disable-sdltest --disable-vorbistest
make
make install
make distclean

echo " "
echo -e $YELLOW"LIBTHEORA Installation Completed"$RESET
echo " "
sleep 2
}

function LIBASS_INSTALL
{
echo " "
echo -e $GREEN"Starting LIBASS Installation"$RESET
echo " "
sleep 2

#Install LIBASS
cd ${CHAN_DIR}
curl -L -O https://github.com/libass/libass/releases/download/${LIBASS_VER}/libass-${LIBASS_VER}.tar.gz
tar zxvf libass-${LIBASS_VER}.tar.gz
cd libass-${LIBASS_VER}
autoreconf -fiv
./configure --prefix="${DEST_DIR}" --disable-shared
make
make install
make distclean

echo " "
echo -e $YELLOW"LIBASS Installation Completed"$RESET
echo " "
sleep 2
}

function ZIMG_INSTALL
{
echo " "
echo -e $GREEN"Starting ZIMG Installation"$RESET
echo " "
sleep 2

#Install ZIMG
cd ${CHAN_DIR}
git clone --depth=1 https://github.com/sekrit-twc/zimg
cd zimg
./autogen.sh
./configure --prefix="${DEST_DIR}" --bindir="${BIND_DIR}" --disable-shared --with-pic
make
make install
make distclean

echo " "
echo -e $YELLOW"ZIMG Installation Completed"$RESET
echo " "
sleep 2
}

function FFMPEG_INSTALL
{
echo " "
echo -e $GREEN"Starting FFMPEG Installation"$RESET
echo " "
sleep 2

#Install FFMPEG
cd ${CHAN_DIR}
git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
export TMPDIR=${TMP_DIR}
mkdir -p $TMPDIR
export PATH="${CUDA_DIR}/bin:$PATH"
PKG_CONFIG_PATH="${DEST_DIR}/lib/pkgconfig" ./configure --prefix="${DEST_DIR}" --pkg-config-flags="--static" --extra-cflags="-I${DEST_DIR}/include -I${CUDA_DIR}/include" --extra-ldflags="-L${DEST_DIR}/lib -L${CUDA_DIR}/lib64" --extra-libs="-lpthread -lm" --bindir="${BIND_DIR}" --enable-gpl --enable-nonfree --enable-cuda --enable-cuda-nvcc --enable-cuvid --enable-vaapi --enable-libnpp --enable-gpl --enable-libfdk_aac --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libtheora --enable-libx265 --enable-libaom --enable-libass --enable-libfreetype --enable-nvenc --enable-libzimg
make
make install
make distclean
#hash -d ffmpeg
ldconfig
echo " "
echo -e $YELLOW"FFMPEG Installation Completed"$RESET
echo " "
sleep 2
}

function QTFASTSTART_INSTALL
{
echo " "
echo -e $GREEN"Starting QT-FASTSTART Installation"$RESET
echo " "
sleep 2

cd ${CHAN_DIR}/ffmpeg/tools
make qt-faststart
cp qt-faststart ${BIND_DIR}

echo " "
echo -e $YELLOW"Install QT-FASTSTART Completed"$RESET
echo " "
}

CUDA_INSTALL
NVCODEC_INSTALL
NASM_INSTALL
YASM_INSTALL
X264_INSTALL
X265_INSTALL
AOM_INSTALL
FDKACC_INSTALL
MP3LAME_INSTALL
OPUS_INSTALL
LIBOGG_INSTALL
LIBVORBIS_INSTALL
LIBVPX_INSTALL
LIBTHEORA_INSTALL
LIBASS_INSTALL
ZIMG_INSTALL
FFMPEG_INSTALL
QTFASTSTART_INSTALL
