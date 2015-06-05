#!/bin/bash
echo "Welcome to Velvet Kernel Builder!"
LC_ALL=C date +%Y-%m-%d
export PATH=$(pwd):/home/arnavgosain/velvet/toolchains/aarch64-linux-android-4.9/bin:$PATH
kernel_dir=$PWD
toolchain="aarch64-linux-android-"
if [ "$device" = "tomato-64" ]; then
build=/home/arnavgosain/velvet/out/tomato
fi
if [ "$device" = "lettuce-64" ]; then
build=/home/arnavgosain/velvet/out/lettuce
fi
kernel="velvet"
version="R1"
rom="cm"
vendor="yu"
if [ "$device" = "tomato-64" ]; then
device_name=tomato
fi
if [ "$device" = "lettuce-64" ]; then
device_name=lettuce
fi
zip=zip-$device
date=`date +%Y%m%d`
config=velvet_"$device"_defconfig
kerneltype="Image"
jobcount="-j$(grep -c ^processor /proc/cpuinfo)"
modules_dir=$kernel_dir/"$zip"/system/lib/modules
export KBUILD_BUILD_USER=arnavgosain
export KBUILD_BUILD_HOST=velvet

echo "Checking for build..."
if [ -d arch/arm64/boot/"$kerneltype" ]; then
	read -p "Previous build found, clean working directory..(y/n)? : " cchoice
	case "$cchoice" in
		y|Y )
			rm -rf "$zip"/system
			mkdir -p "$zip"/system/lib/modules
			export ARCH=arm64
			export CROSS_COMPILE=$toolchain
			make clean && make mrproper
			echo "Working directory cleaned...";;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " dchoice
	case "$dchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;

		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi
echo "Extracting files..."
if [ -f arch/arm64/boot/"$kerneltype" ]; then
	cp arch/arm64/boot/"$kerneltype" "$zip"/tools/"$kerneltype"
	find . -name '*.ko' -exec cp {} $modules_dir/ \;
	"$toolchain"strip --strip-unneeded "$zip"/system/lib/modules/*.ko &> /dev/null
else
	echo "Nothing has been made..."
	read -p "Clean working directory..(y/n)? : " achoice
	case "$achoice" in
		y|Y )
			rm -rf "$zip"/system
			mkdir -p "$zip"/system/lib/modules
			export ARCH=arm64
                        export CROSS_COMPILE=$toolchain
                        make clean && make mrproper
                        echo "Working directory cleaned...";;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " bchoice
	case "$bchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi

echo ""$zip"ping..."
if [ -f "$zip"/tools/"$kerneltype" ]; then
	cd "$zip"
	"$zip" -r ../"$kernel"."$version"-"$rom"."$vendor"."$device"."$date"."$zip" .
	mv ../"$kernel"."$version"-"$rom"."$vendor"."$device"."$date"."$zip" $build
	rm tools/"$kerneltype"
	cd ..
	rm -rf arch/arm64/boot/"$kerneltype"
	export outdir="$build"
	echo "Done..."
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi
# Export script by Savoca
# Thank You Savoca!
