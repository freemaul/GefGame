#!/bin/bash
#
#    This file is part of GefGame.
#
#    GefGame is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    GefGame is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#


## Versions of Mingw and Win32
mingw_version="3.3"
win32_version="2.5"

#mingw_arch=""
#mingw_url=""
#mingw_untar=""

#win32_url=""
#win32_arch=""
#win32_untar=""

## Others versions
binutils_version="2.20.1"
#binutils_version="2.14"

gmp_version="4.3.2"
mpfr_version="2.4.2"
mpc_version="0.8.1"
gcc_version="4.5.1"
#gcc_version="3.4.0"

#gcc_core_win_version="4.5.0-1"
#gcc_core_win_arch="gcc-core-4.5.0-1-mingw32-bin.tar.lzma"
#gcc_core_win_url="http://sourceforge.net/projects/mingw/files/MinGW/BaseSystem/GCC/Version4/gcc-4.5.0-1/gcc-core-4.5.0-1-mingw32-bin.tar.lzma/download"
#gcc_cpp_win_version="4.5.0-1"
#gcc_cpp_win_arch="gcc-c++-4.5.0-1-mingw32-bin.tar.lzma"
#gcc_cpp_win_url="http://sourceforge.net/projects/mingw/files/MinGW/BaseSystem/GCC/Version4/gcc-4.5.0-1/gcc-c%2B%2B-4.5.0-1-mingw32-bin.tar.lzma/download"

#gcc_win_untar="tar --lzma xf"


display_help()
{
	echo -e "Syntax :"
	echo -e "\tmake_cross.sh [target]"
	echo -e "Targets :"
	for target in `./target.sh | cut -f1 -d:`; do
		echo -e "\t$target"
	done
}

download()
{
	mkdir -p download
	cd download
	wget --continue $1 || { cd .. && return 1; }
	cd ..
}

copy_log()
{
	mkdir -p logs
	for file in `find $1 2>/dev/null | grep "\.log"`; do
		file_log=${file//"/"/"_"}
		cp -f $file logs/$file_log || { return 1; }
	done
}

build_mingw()
{
	## Download mingw


	download http://sourceforge.net/projects/mingw/files/MinGW/BaseSystem/RuntimeLibrary/MinGW-RT/mingw-runtime-3.14/mingw-runtime-3.14.tar.gz || { return 1; }
	download http://sourceforge.net/projects/mingw/files/MinGW/BaseSystem/RuntimeLibrary/Win32-API/w32api-3.13/w32api-3.13-mingw32-dev.tar.gz || { return 1; }

	mkdir -p $target
	cd $target
	tar zxf ../download/mingw-runtime-3.14.tar.gz || { cd .. && return 1; }
	tar zxf ../download/w32api-3.13-mingw32-dev.tar.gz || { cd .. && return 1; }
	cd ..
}

build_binutils()
{
	## Test if binutils already install
	check=`ls $target/bin/ 2>/dev/null | grep $target_config-ld`
	if [[ $check != "" ]]; then
		echo "binutils is already install, bypass"
		return 0;
	fi

	## Download binutils
	download "ftp://ftp.gnu.org/gnu/binutils/binutils-$binutils_version.tar.bz2" || { return 1; }	
	## Extract binutils
	tar xfj "download/binutils-$binutils_version.tar.bz2" || { return 1; }
	## Make build folder
	rm -rf binutils-build || { return 1; }
	mkdir -p binutils-build	|| { return 1; }
	## Configure binutils
	cd binutils-build || { return 1; }
	../binutils-$binutils_version/configure --prefix="$GEFGAME/cross/FromLinux/$target" --target="$target_config" --disable-boostrap || { return 1; }
	## Make and install binutils
	make  || { cd .. && return 1; }
	make install  || { cd .. && return 1; }
	cd ..
	## copy logfiles
	copy_log binutils-build
	## Delete build folder and source folder
	rm -rf binutils-build || { return 1; }
	rm -rf binutils-$binutils_version || { return 1; }
}

build_gmp()
{
	## Test if gmp already install
	check=`ls $target/include/ 2>/dev/null | grep "gmp\.h"`
	if [[ $check != "" ]]; then
		echo "gmp is already install, bypass"
		return 0;
	fi

	## Download gmp
	download "ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-$gmp_version.tar.bz2" || { return 1; }
	## Extract gmp
	tar xfj "download/gmp-$gmp_version.tar.bz2" || { return 1; }
	## Make build folder
	rm -rf gmp_build || { return 1; }
	mkdir -p gmp_build || { return 1; }
	## Configure gmp
	cd gmp_build || { return 1; }
	../gmp-$gmp_version/configure --prefix="$GEFGAME/cross/FromLinux/$target" --disable-shared || { cd .. && return 1; }
	## Make an dinstall gmp
	make || { cd .. && return 1; }
	make install || { cd .. && return 1; }
	cd ..
	## copy logfiles
	copy_log gmp_build
	## Delete build folder and source folder
	rm -rf gmp_build || { return 1; }
	rm -rf gmp-$gmp_version || { return 1; }
}


build_mpfr()
{
	## Test if mpfr already install
	check=`ls $target/include/ 2>/dev/null | grep "mpfr\.h"`
	if [[ $check != "" ]]; then
		echo "mpfr is already install, bypass"
		return 0;
	fi

	## download mpfr
	download "ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-$mpfr_version.tar.bz2" || { return 1; }
	## Extract mpfr
	tar xfj "download/mpfr-$mpfr_version.tar.bz2" || { cd .. && return 1; }
	## Make build folder
	rm -rf mpfr_build || { return 1; }
	mkdir -p mpfr_build || { return 1; }
	## Configure mpfr
	cd mpfr_build || { return 1; }
	../mpfr-$mpfr_version/configure --prefix="$GEFGAME/cross/FromLinux/$target" --with-gmp="$GEFGAME/cross/FromLinux/$target" --disable-shared || { cd .. && return 1; }
	## Make and install mpfr
	make || { cd .. && return 1; }
	make install || { cd .. && return 1; }
	cd ..
	## copy logfiles
	copy_log mpfr_build
	## Delete build folder and source folder
	rm -rf mpfr_build || { return 1; }
	rm -rf mpfr-$mpfr_version || { return 1; }
}

build_mpc()
{
	## Test if mpc already install
	check=`ls $target/include/ 2>/dev/null | grep "mpc\.h"`
	if [[ $check != "" ]]; then
		echo "mpc is already install, bypass"
		return 0;
	fi

	## Download mpc
	download "ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-$mpc_version.tar.gz" || { return 1; }
	## Extract mpc
	tar zxf download/mpc-$mpc_version.tar.gz || { cd .. && return 1; }
	## Make build folder
	rm -rf mpc_build || { return 1; }
	mkdir -p mpc_build || { return 1; }
	## Configure mpc
	cd mpc_build || { return 1; }
	../mpc-$mpc_version/configure --target=$target_config --prefix="$GEFGAME/cross/FromLinux/$target" --with-gmp="$GEFGAME/cross/FromLinux/$target" --with-mpfr="$GEFGAME/cross/FromLinux/$target" --disable-shared || { cd .. && return 1; }
	## Make and install mpc
	make || { cd .. && return 1; }
	make install || { cd .. && return 1; }
	cd ..
	## copy logfiles
	copy_log mpc-build
	## Delete build folder and source folder
	rm -rf mpc_build || { return 1; }
	rm -rf mpc-$mpc_version || { return 1; }
}

build_gcc_linux()
{
	gcc_conf_flags="--disable-nls --without-headers --enable-languages=c,c++ --disable-boostrap --without-headers"

	if [[ $gcc_version > "4.3.0" || $gcc_version = "4.3.0" ]]; then
		# gcc >= 4.3.0 need gmp and mpfr
		build_gmp || { return 1; }
		gcc_conf_flags=$gcc_conf_flags" --with-gmp=$GEFGAME/cross/FromLinux/$target"
		build_mpfr || { return 1; }
		gcc_conf_flags=$gcc_conf_flags" --with-mpfr=$GEFGAME/cross/FromLinux/$target"
	fi
	if [[ $gcc_version > "4.5.0" || $gcc_version = "4.5.0" ]]; then
		# gcc >= 4.5.0 need mpc too
		build_mpc || { return 1; }
		gcc_conf_flags=$gcc_conf_flags" --with-mpc=$GEFGAME/cross/FromLinux/$target"
	fi

	## Download gcc
	download "ftp://ftp.gnu.org/gnu/gcc/gcc-$gcc_version/gcc-core-$gcc_version.tar.bz2" || { return 1; }
	download "ftp://ftp.gnu.org/gnu/gcc/gcc-$gcc_version/gcc-g++-$gcc_version.tar.bz2" || { return 1; }
	## Extract gcc
	tar xfj download/gcc-core-$gcc_version.tar.bz2 || { return 1; }
	tar xfj download/gcc-g++-$gcc_version.tar.bz2 || { return 1; }
	## Make build folder
	rm -rf gcc-build || { return 1; }
	mkdir -p gcc-build || { return 1; }
	## Configure gcc
	cd gcc-build || { return 1; }
#	export PATH=$PATH:$GEFGAME/cross/FromLinux/$target/bin/
	../gcc-$gcc_version/configure --prefix=$GEFGAME/cross/FromLinux/$target --target=$target_config $gcc_conf_flags || { cd .. && return 1; }
	## Make and install gcc
	make || { cd .. && return 1; }
	make install || { cd .. && return 1; }
	cd ..
	## copy logfiles
	copy_log gcc-build
	## Delete build folder and source folder
	rm -rf gcc-build || { return 1; }
	rm -rf gcc-$gcc_version || { return 1; }


##	download "ftp://sources.redhat.com/pub/newlib/newlib-1.18.0.tar.gz" || { return 1; }

##################################### GCC-4.5.2 ALL
##	download "ftp://ftp.gnu.org/gnu/gcc/gcc-4.5.2/gcc-4.5.2.tar.gz" || { return 1; }
##	tar zxf download/gcc-4.5.2.tar.gz || { return 1; }
##	cd gcc-4.5.2
##################################### GCC-4.5.1
#	download "ftp://ftp.gnu.org/gnu/gcc/gcc-4.5.1/gcc-core-4.5.1.tar.bz2" || { return 1; }
#	download "ftp://ftp.gnu.org/gnu/gcc/gcc-4.5.1/gcc-g++-4.5.1.tar.bz2" || { return 1; }
#	tar xfj download/gcc-core-4.5.1.tar.bz2 || { return 1; }
#	tar xfj download/gcc-g++-4.5.1.tar.bz2 || { return 1; }
#	cd gcc-4.5.1
##################################### GCC-4.5.2
#	download "ftp://ftp.gnu.org/gnu/gcc/gcc-4.5.2/gcc-core-4.5.2.tar.bz2" || { return 1; }
#	download "ftp://ftp.gnu.org/gnu/gcc/gcc-4.5.2/gcc-g++-4.5.2.tar.bz2" || { return 1; }
#	tar xfj download/gcc-core-4.5.2.tar.bz2 || { return 1; }
#	tar xfj download/gcc-g++-4.5.2.tar.bz2 || { return 1; }
#	cd gcc-4.5.2


##	tar zxf ../download/mingw-runtime-3.14.tar.gz || { cd .. && return 1; }
#	cd ..

#	rm -rf gcc-build
#	mkdir -p gcc-build
#	cd gcc-build

#	export PATH=$PATH:$GEFGAME/cross/FromLinux/$target/bin/
#	../gcc-4.5.1/configure --prefix=$GEFGAME/cross/FromLinux/$target --target=$target_config --disable-nls --without-headers --enable-languages=c,c++ --disable-boostrap --without-headers --with-gmp="$GEFGAME/cross/FromLinux/$target" --with-mpfr="$GEFGAME/cross/FromLinux/$target" --with-mpc="$GEFGAME/cross/FromLinux/$target"

#	make  all-gcc || { cd .. && return 1; }
#	make install-gcc  || { cd .. && return 1; }
#	cd ..	

#	tar xfz newlib-1.18.0.tar.gz
#	mkdir -p newlib-build
#	cd newlib-build
#	../newlib-1.18.0/configure --prefix=$GEFGAME/cross/$target --target=$target_config
#	make || { cd .. && return 1; }
#	make install || { cd .. && return 1; }
#	cd ..

#	cd gcc-build
#	make distclean
#	../gcc-4.5.2/configure --prefix=$GEFGAME/cross/FromLinux/$target --target=$target_config --with-newlib
#	make || { cd .. && return 1; }
#	make install || { cd .. && return 1; }
#	cd ..	
}

build_gcc_win()
{
	build_gcc_linux
	## Download gcc
#	download "$gcc_core_win_url" || { return 1; }
#	download "$gcc_cpp_win_url" || { return 1; }
	## Extract gcc
#	echo "$gcc_win_untar \"download/$gcc_core_win_arch\""
#	$gcc_win_untar "download/$gcc_core_win_arch" || { return 1; }
#	$gcc_win_untar "download/$gcc_cpp_win_arch" || { return 1; }

}


build()
{
	temp=`echo $target | grep Win`

	build_binutils || { return 1; }
	if [[ $temp != "" ]]; then
		# if target windows, we need mingw
#		build_mingw || { return 1; }
		build_gcc_win || { return 1; }
	else
		build_gcc_linux || { return 1; }
	fi


}

if [[ $GEFGAME == "" ]];then
	echo "Install GEFGAME please"
	exit 1;
fi

target=$1
if [[ $target == "" ]];then
	display_help
	exit 1
fi

for temp in `./target.sh`; do
	temp_target=`echo $temp | cut -f1 -d:`
	target_config=`echo $temp | cut -f2 -d:`
	if [[ $target == $temp_target ]]; then
		build || exit 1
		exit 0
	fi
done

echo "$target not found"
exit 1
