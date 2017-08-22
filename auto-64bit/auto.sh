#! /bin/bash

RPMDIR=rpms
SOURCEDIR=sources
OPT=/home/opt
LOGDIR=/var/iCross-Auto-Shell

# rpm packages
GLIBCDEVDIR=$RPMDIR/glibc-devel-2.4-25.x86_64.rpm
GCCDIR=$RPMDIR/gcc-4.1.0-25.x86_64.rpm
LIBSTDDIR=$RPMDIR/libstdc++-4.1.0-25.x86_64.rpm
LIBSTDDEVDIR=$RPMDIR/libstdc++-devel-4.1.0-25.x86_64.rpm
GPPDIR=$RPMDIR/gcc-c++-4.1.0-25.x86_64.rpm
KERNELDIR=$RPMDIR/kernel-source-2.6.16.13-4.x86_64.rpm
ZLIBDEVDIR=$RPMDIR/zlib-devel-1.2.3-13.x86_64.rpm
READLINEDEVDIR=$RPMDIR/readline-devel-5.1-22.x86_64.rpm
WGETDIR=$RPMDIR/wget-1.10.2-13.x86_64.rpm
ZIPDIR=$RPMDIR/zip-2.31-13.x86_64.rpm
UNZIPDIR=$RPMDIR/unzip-5.52-14.x86_64.rpm

# temporary build dir
CODETMP=$SOURCEDIR/codetmp
BUILDDIR=$SOURCEDIR/buildtmp

# tool sources tar
XZDIR=$SOURCEDIR/xz-5.2.3.tar.bz2
BINDIR=$SOURCEDIR/binutils-2.25.1.tar.bz2
GCCNEWDIR=$SOURCEDIR/gcc-7.2.0.tar.gz
M4DIR=$SOURCEDIR/m4-1.4.14.tar.gz
AUTOCONFDIR=$SOURCEDIR/autoconf-2.68.tar
AUTOMAKEDIR=$SOURCEDIR/automake-1.14.1.tar.gz
MAKEDIR=$SOURCEDIR/make-4.2.1.tar.bz2
LIBTOOLDIR=$SOURCEDIR/libtool-2.4.4.tar.gz


# lib sources tar
NSSDIR=$SOURCEDIR/nss-3.32-with-nspr-4.16.tar.gz
LUAJITDIR=$SOURCEDIR/LuaJIT-2.0.5.tar.gz
PCRE2DIR=$SOURCEDIR/pcre2-10.23.tar.bz2
LIBUVDIR=$SOURCEDIR/libuv-v1.13.1.tar.gz
WOLFSSLDIR=$SOURCEDIR/wolfssl-3.12.0.zip

# libiberty.a
PIC=libiberty-pic/libiberty.a

# include .h files
PTRACE=include/ptrace.h
INPUT=include/input.h
FS=include/fs.h

function rpm_install(){
	rpm -qa |grep '^glibc-devel.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $GLIBCDEVDIR >> /dev/null
	fi
	echo 'glibc-devel has been installed' >> /var/iCross.log
	rpm -qa |grep '^gcc.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $GCCDIR >> /dev/null
	fi
	echo 'gcc has been installed' >> /var/iCross.log
	rpm -qa |grep '^libstdc++.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $LIBSTDDIR >> /dev/null
	fi
	echo 'libstdc++ has been installed' >> /var/iCross.log
	rpm -qa |grep '^libstdc++-devel.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $LIBSTDDEVDIR >> /dev/null
	fi
	echo 'libstdc++-devel has been installed' >> /var/iCross.log
	rpm -qa |grep '^gcc-c++.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $GPPDIR >> /dev/null
	fi
	echo 'gcc-c++ has been installed' >> /var/iCross.log
	rpm -qa |grep '^kernel-source.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $KERNELDIR >> /dev/null
	fi
	echo 'kernel-source has been installed' >> /var/iCross.log
	rpm -qa |grep '^zlib-devel.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $ZLIBDEVDIR >> /dev/null
	fi
	echo 'zlib-devel has been installed' >> /var/iCross.log
	rpm -qa |grep '^readline-devel.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $READLINEDEVDIR >> /dev/null
	fi
	echo 'readline-devel has been installed' >> /var/iCross.log
	rpm -qa |grep '^wget.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $WGETDIR >> /dev/null
	fi
	echo 'wget has been installed' >> /var/iCross.log
	rpm -qa |grep '^zip.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $ZIPDIR >> /dev/null
	fi
	echo 'zip has been installed' >> /var/iCross.log
	rpm -qa |grep '^unzip.*$' >> /dev/null
	if [[ $? -ne 0 ]]; then
		rpm -ivh $UNZIPDIR >> /dev/null
	fi
	echo 'unzip has been installed' >> /var/iCross.log
}

function part_tool_install(){
	echo $1 installing...
	mkdir $CODETMP
	tar -xf $1 --strip-components=1 -C $CODETMP
	mkdir $BUILDDIR && cd $BUILDDIR
	name=`echo $1 | cut -d "/" -f 2 | cut -d "-" -f 1`
	$OLDPWD/$CODETMP/configure --prefix=/usr 1> $LOGDIR/$name-configure.log 2>&1
	make 1> $LOGDIR/$name-make.log 2>&1
	if [[ $? -ne 0 ]]; then
		echo $1 make fail!
		exit
	fi
	make install 1> $LOGDIR/$name-makeinstall.log 2>&1
	ldconfig 1> /dev/null 2>&1
	cd $OLDPWD
	rm -rf $CODETMP
	rm -rf $BUILDDIR
	echo $1 finish
}

function gcc_install(){
	echo 'gcc 7.2.0 installing...'
	mkdir $CODETMP
	tar -xf $GCCNEWDIR --strip-components=1 -C $CODETMP
	cd $CODETMP
	./contrib/download_prerequisites --no-verify 1> $LOGDIR/gcc-predownload.log 2>&1
	cd $OLDPWD
	mkdir $BUILDDIR && cd $BUILDDIR
	$OLDPWD/$CODETMP/configure --prefix=/usr \
	                           --enable-checking=release \
	                           --enable-languages=c,c++ \
	                           --enable-threads=posix \
	                           --disable-multilib 1> $LOGDIR/gcc-configure.log 2>&1
	make 1> $LOGDIR/gcc-make1.log 2>&1
	if [[ $? -ne 0 ]]; then
		cp $OLDPWD/$PIC ./libiberty/pic/libiberty.a
	fi
	make 1> $LOGDIR/gcc-make2.log 2>&1
	# if [[ $? -ne 0 ]]; then
	# 	sed -i '106s/[ ]/\n/' $OLDPWD/$CODETMP/libgcc/config/t-softfp
	# 	sed -i '$ aendif' $OLDPWD/$CODETMP/libgcc/config/t-softfp
	# fi
	# make 1> $LOGDIR/gcc-make3.log 2>&1
	if [[ $? -ne 0 ]]; then
		cp $OLDPWD/$PTRACE /usr/include/sys/ptrace.h
		cp $OLDPWD/$INPUT /usr/include/linux/input.h
		cp $OLDPWD/$FS /usr/include/linux/fs.h
	fi
	make 1> $LOGDIR/gcc-make4.log 2>&1
	if [[ $? -ne 0 ]]; then
		echo 'GCC 7.2.0 make fail! Exit!' >> /var/iCross.log
		exit
	fi
	make install 1> $LOGDIR/gcc-makeinstall.log 2>&1
	cp /usr/lib64/libgcc_s.so.1 /lib64/libgcc_s.so.1
	cd $OLDPWD
	rm -rf $CODETMP
	rm -rf $BUILDDIR
	echo 'gcc 7.2.0 finish'
}

function tool_install(){
	if [[ $1 = $GCCNEWDIR ]]; then
		gcc_install
	else
		part_tool_install $1
	fi
}

function lib_install(){
	mkdir -p $OPT $OPT/bin $OPT/lib $OPT/include $OPT/share $OPT/src
	
	ls $OPT/src |grep nss >> /dev/null
	if [[ $? -ne 0 ]]; then
		echo 'NSS installing...'
		mkdir $CODETMP
		tar -xf $NSSDIR --strip-components=1 -C $CODETMP
		cd $CODETMP/nss
		export BUILD_OPT=1
		export USE_64=1
		make nss_build_all 1> $LOGDIR/nss-make.log 2>&1
		if [[ $? -ne 0 ]]; then
			echo 'NSS make fail!'
			exit
		fi
		cd $OLDPWD
		mv $CODETMP $OPT/src/nss-3.32
		echo 'NSS 3.32 has been installed' >> /var/iCross.log
		echo 'NSS finish'
	fi

	ls $OPT/src |grep LuaJIT >> /dev/null
	if [[ $? -ne 0 ]]; then
		echo 'Luajit installing...'
		mkdir $CODETMP
		tar -xf $LUAJITDIR --strip-components=1 -C $CODETMP
		cd $CODETMP
		make 1> $LOGDIR/luajit-make.log 2>&1
		if [[ $? -ne 0 ]]; then
			echo 'LuaJIT make fail!'
			exit
		fi
		make install PREFIX=$OPT 1> $LOGDIR/luajit-makeinstall.log 2>&1
		cd $OLDPWD
		mv $CODETMP $OPT/src/LuaJIT-2.0.5
		echo 'LuaJIT 2.0.5 has been installed' >> /var/iCross.log
		echo 'Luajit finish'
	fi

	ls $OPT/src |grep pcre2 >> /dev/null
	if [[ $? -ne 0 ]]; then
		echo 'pcre2 installing...'
		mkdir $CODETMP
		tar -xf $PCRE2DIR --strip-components=1 -C $CODETMP
		cd $CODETMP
		./configure --prefix=$OPT --enable-unicode \
								  --enable-pcre2-16 \
								  --enable-pcre2-32 \
								  --enable-pcre2grep-libz \
								  --enable-pcre2grep-libbz2 \
								  --enable-pcre2test-libreadline \
								  --disable-static 1> $LOGDIR/pcre2-configure.log 2>&1
		make 1> $LOGDIR/pcre2-make.log 2>&1
		if [[ $? -ne 0 ]]; then
			echo 'pcre2 make fail!'
			exit
		fi
		make install 1> $LOGDIR/pcre2-makeinstall.log 2>&1
		cd $OLDPWD
		mv $CODETMP $OPT/src/pcre2-10.23
		echo 'pcre2 10.23 has been installed' >> /var/iCross.log
		echo 'pcre2 finish'
	fi

	ls $OPT/src |grep libuv >> /dev/null
	if [[ $? -ne 0 ]]; then
		echo 'libuv installing...'
		mkdir $CODETMP
		tar -xf $LIBUVDIR --strip-components=1 -C $CODETMP
		cd $CODETMP
		sh autogen.sh 1> $LOGDIR/libuv-autogen.log 2>&1
		./configure --prefix=$OPT 1> $LOGDIR/libuv-configure.log 2>&1
		make 1> $LOGDIR/libuv-make.log 2>&1
		if [[ $? -ne 0 ]]; then
			echo 'libuv make fail!'
			exit
		fi
		make install 1> $LOGDIR/libuv-makeinstall.log 2>&1
		cd $OLDPWD
		mv $CODETMP $OPT/src/libuv-v1.13.1
		echo 'libuv 1.13.1 has been installed' >> /var/iCross.log
		echo 'libuv finish'
	fi

	ls $OPT/src |grep wolfssl >> /dev/null
	if [[ $? -ne 0 ]]; then
		echo 'wolfssl installing...'
		mkdir $CODETMP
		unzip $WOLFSSLDIR -d $CODETMP >> /dev/null
		cd $CODETMP/wolfssl-3.12.0
		./configure --prefix=$OPT 1> $LOGDIR/wolfssl-configure.log 2>&1
		make 1> $LOGDIR/wolfssl-make.log 2>&1
		if [[ $? -ne 0 ]]; then
			echo 'wolfssl make fail!'
			exit
		fi
		make install 1> $LOGDIR/wolfssl-makeinstall.log 2>&1
		cd $OLDPWD
		mv $CODETMP/wolfssl-3.12.0 $OPT/src/wolfssl-3.12.0
		rm -rf $CODETMP
		echo 'WolfSSL 3.12.0 has been installed' >> /var/iCross.log
		echo 'wolfssl finish'
	fi
}

function check_install(){
	toolversion=`$1 --version | awk 'NR==1{print $n}' n="$3" `
	if [[ $toolversion != $2 ]]; then
		tool_install $4
	fi
	echo $1 $2 has been installed >> /var/iCross.log
}

date > /var/iCross.log

mkdir -p $LOGDIR

rpm_install

check_install xz 5.2.3 4 $XZDIR
check_install ld 2.25.1 5 $BINDIR
check_install libtool 2.4.4 4 $LIBTOOLDIR
check_install gcc 7.2.0 3 $GCCNEWDIR
check_install m4 1.4.14 4 $M4DIR
check_install autoconf 2.68 4 $AUTOCONFDIR
check_install automake 1.14.1 4 $AUTOMAKEDIR
check_install make 4.2.1 3 $MAKEDIR

lib_install

date >> /var/iCross.log