#!/bin/bash
echo "Welcome to Velvet Kernel Builder!"
LC_ALL=C date +%Y-%m-%d
export PATH=$(pwd):/home/arnavgosain/velvet/toolchains/aarch64-linux-android-4.9/bin:$PATH
kernel_dir=$PWD
toolchain="aarch64-linux-android-"
kernel="velvet"
version="R2"
vendor="yu"
if [ "$device" = "tomato-64" ]; then
build=/home/arnavgosain/velvet/out/tomato/$rom/
fi
if [ "$device" = "lettuce-64" ]; then
build=/home/arnavgosain/velvet/out/lettuce/$rom/
fi
if [ "$device" = "tomato-64" ]; then
device_name=tomato
fi
if [ "$device" = "lettuce-64" ]; then
device_name=lettuce
fi
zip=zip-$device_name
date=`date +"%Y%m%d-%H%M"`
config=velvet_"$device"_defconfig
kerneltype="Image"
jobcount="-j$(grep -c ^processor /proc/cpuinfo)"
modules_dir=$kernel_dir/"$zip"/system/lib/modules
zip_name="$kernel"."$version"_"$device"_"$date".zip
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

echo "Zipping..."
if [ -f "$zip"/tools/"$kerneltype" ]; then
	cd "$zip"
	zip -r ../$zip_name .
	mv ../$zip_name $build
	rm tools/"$kerneltype"
	cd ..
	rm -rf arch/arm64/boot/"$kerneltype"
	export outdir="$build"
	echo "Package complete: "$build"/"$zip_name""
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi
# Export script by Savoca
# Thank You Savoca!
