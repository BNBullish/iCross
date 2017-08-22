## 编译环境搭建

*旧的发行版安装新的GCC*

### 32位(LFS6.2)

#### 准备工作

1. LFS提供的镜像 http://mirror.bjtu.edu.cn/lfs-livecd/lfslivecd-x86-6.2-5.iso

2. 使用ALFS脚本构建LFS系统，脚本运行结束后

   1. 参考LFS文档 http://www.linuxfromscratch.org/lfs/view/6.2/index.html
   2. 编译内核时注意磁盘、文件系统和网络设备等的支持
   3. grub的启动文件中SCSI硬盘也是`root=(hd0,1)`(sda2为例)

3. 参考BLFS文档 http://www.linuxfromscratch.org/blfs/view/6.2.0/ 安装需要的软件

   如 openssl, wget, openssh

4. 下载gcc5.2包

####  安装gcc5.2

1. 解压进入gcc5.2源码目录，执行如下脚本安装MPFR,GMP,MPC,ISL

   `./contrib/download_prerequisites`

2. 在源码路径之外新建一个文件夹并进入

3. 执行 `unset CPLUS_INCLUDE_PATH LIBRARY_PATH C_INCLUDE_PATH` 避免之后的头文件库文件找不到

4. ```
   ../gcc-5.2.0/configure --prefix=/usr/local/gcc-520 \
   --enable-checking=release \
   --enable-languages=c,c++ \
   --disable-multilib \
   --enable-threads=posix
   ```

5. `make`

6. `make install`

- `make`期间的错误修改：

  1. `vim ../gcc-5.2.0/libgcc/config/t-softfp` 

     106行把else和ifneq分为两行

     ```
     else
     ifneq ($(softfp_wrap_start),)
     ```

     113行在文件末尾加一行 `endif`

  2. 很多宏没有定义

     ```
     vim /usr/include/sys/ptrace.h
     vim /usr/include/linux/fs.h
     vim /usr/include/linux/input.h
     ```

     如上几个文件包含了缺失的宏，可去其他系统把对应的定义复制过来

#### 使用gcc5.2

1. 环境变量设置

   **64位**

   ```
   export LD_LIBRARY_PATH=/usr/local/gcc-520/lib64:$LD_LIBRARY_PATH &&
   export LD_RUN_PATH=/usr/local/gcc-520/lib64:$LD_RUN_PATH &&
   export PATH=/usr/local/gcc-520/bin:$PATH
   ```

   **32位**

   ```
   export LD_LIBRARY_PATH=/usr/local/gcc-520/lib:$LD_LIBRARY_PATH &&
   export LD_RUN_PATH=/usr/local/gcc-520/lib:$LD_RUN_PATH &&
   export PATH=/usr/local/gcc-520/bin:$PATH
   ```

2. 编译

   ```
   g++ -std=c++11 -static-libstdc++ -static-libgcc
   ```




### 64位(SUSE10sp2)

#### 准备工作(Ysat2图形界面)

1. 添加网络源，禁用CD源

   `http://romolo.cmb.usc.edu/installs/SLE-10-SP2-SDK-x86_64/CD1/`

2. 下载安装 gcc  gcc-c++  wget  kernel-source

3. SUSE系统选择英文，若为中文系统则编译过程中一些makefile文件会乱码以至于不能读

#### 其余工作与32位类似



### 备注-软件版本查看

##### 32位LFS6.2

```
bash, version 3.1.17(1)-release
/bin/sh -> /bin/bash
Binutils: version 2.16.1
bison (GNU Bison) 2.2
yacc is bison (GNU Bison) 2.2
bzip2,  Version 1.0.3, 15-Feb-2005.
Coreutils:  5.96
diff (GNU diffutils) 2.8.1
GNU find version 4.2.27
GNU Awk 3.1.5
/usr/bin/awk -> /usr/bin/gawk
gcc (GCC) 5.2.0
g++ (GCC) 5.2.0
(GNU libc) 2.3.6
grep (GNU grep) 2.5.1
gzip 1.3.5
Linux version 2.6.16.27 (root@lfslivecd) (gcc version 4.0.3) #1 SMP PREEMPT Thu Aug 10 09:36:10 GMT 2017
GNU M4 1.4.4
GNU Make 3.80
patch 2.5.4
Perl version='5.8.8';
GNU sed version 4.1.5
tar (GNU tar) 1.15.1
makeinfo (GNU texinfo) 4.8
version-check.sh: line 48: xz: command not found
g++ compilation OK
```

##### 64位SUSE10sp2

```
bash, version 3.1.17(1)-release
/bin/sh -> /bin/bash
Binutils: version 2.16.91.0.5 20051219 (SUSE Linux)
version-check.sh: line 11: bison: command not found
yacc not found
bzip2,  Version 1.0.3, 15-Feb-2005.
Coreutils:  5.93
diff (GNU diffutils) 2.8.7
GNU find version 4.2.27
/usr/bin/awk -> /bin/gawk
gcc (GCC) 5.2.0
g++ (GCC) 5.2.0
(GNU libc) 2.4
grep (GNU grep) 2.5.1
gzip 1.3.5
Linux version 2.6.16.60-0.21-default (geeko@buildhost) (gcc version 4.1.2 20070115 (SUSE Linux)) #1 Tue May 6 12:41:02 UTC 2008
GNU M4 1.4.4
GNU Make 3.80
patch 2.5.9
Perl version='5.8.8';
GNU sed version 4.1.4
tar (GNU tar) 1.15.1
version-check.sh: line 47: makeinfo: command not found
version-check.sh: line 48: xz: command not found
g++ compilation OK
```

