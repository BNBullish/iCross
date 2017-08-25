## 详细介绍

**参见         [iCross](./iCross.md)**             **[参考资料](./Version-Relation.md)**



## 使用说明

iCross  
  ├─auto-32bit		         //32位  
  │  ├─include		         //包含缺少的宏的三个头文件  
  │  ├─libiberty-pic       //编译过程中出错的生成文件  
  │  ├─rpms		             //提前需要安装的rpm包  
  │  ├─sources             //需要编译的源码包  
  │  ├─auto.sh               //自动化部署脚本  
  │  ├─check-tool-version.sh    //检查系统相关工具版本  
  │  └─tool_download_list.txt    //源码下载地址列表  
  ├─auto-64bit		//64位  
  │  ├─include		 //包含缺少的宏的三个头文件  
  │  ├─libiberty-pic       //编译过程中出错的生成文件  
  │  ├─rpms		       //提前需要安装的rpm包  
  │  ├─sources              //需要编译的源码包  
  │  ├─auto.sh               //自动化部署脚本  
  │  ├─check-tool-version.sh    //检查系统相关工具版本  
  │  └─tool_download_list.txt    //源码下载地址列表  
  ├─Records                  //进度与工作内容记录  
  ├─fabfile.py                //用于统一部署测试的简单脚本  
  ├─iCross.md               //项目介绍  
  └─README.md           //详细流程  

- 将`auto-32bit` 或 `auto-64bit` 传至对应系统中
- 进入该目录，执行`bash auto.sh`
- 漫长的等待 ……
- 详细日志存放于 `/var/iCross-Auto-Shell` ，简略日志记录在`/var/iCross.log`
- 简单的检测功能以避免重复安装
- 可自行下载源码包放置于`sources`目录下



## 构建流程

1. 准备好suse10.1镜像

   - SUSE-Linux-10.1-GM-DVD-x86_64.iso
   - SUSE-Linux-10.1-GM-DVD-i386.iso

2. 安装系统

   1. 英文
   2. 地点时钟使用localtime
   3. 不装图形界面系统安装会很快
   4. Network Configuration关闭防火墙或者设置ssh可以通过

3. 需要提前安装的软件(rpm包) `rpm -ivh *`

   ```
   gcc
   libstdc++
   libstdc++-devel
   gcc-c++
   kernel-source
   zlib-devel
   readline-devel
   wget
   zip
   unzip
   ```

4. 源码安装的软件

   ```
   xz
   binutils
   gcc
   m4
   autoconf
   automake
   make
   ```

5. 源码安装的库

   ```
   NSS
   LusJIT
   pcre2
   libuv
   wolfssl
   ```

   ​


## 环境构建流程

### GCC 7.2.0

1. 解压进入gcc5.2源码目录，执行如下脚本安装MPFR,GMP,MPC,ISL

   `./contrib/download_prerequisites --no-verify`

2. 在源码路径之外新建一个文件夹并进入

3. 执行 `unset CPLUS_INCLUDE_PATH LIBRARY_PATH C_INCLUDE_PATH` 避免之后的头文件库文件找不到

4. ```
   ../gcc-5.2.0/configure --prefix=/usr \
   --enable-checking=release \
   --enable-languages=c,c++ \
   --disable-multilib \
   --enable-threads=posix
   ```

5. `make`

6. `make install`

**`make`期间的错误处理**

1. `pic/libiberty.a`文件出错

   把之前生成的该文件复制过来，覆盖掉此处的该文件

2. 很多宏没有定义

   ```
   vim /usr/include/sys/ptrace.h
   vim /usr/include/linux/fs.h
   vim /usr/include/linux/input.h
   ```

   如上几个文件包含了缺失的宏，可去其他系统把对应的定义复制过来

### Others

   `./configure --prefix=/usr && make && make install`




## 库安装流程

### NSS

[构建与测试指导](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/NSS_Sources_Building_Testing)  [环境变量说明](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/Reference/NSS_environment_variables) 

- 下载带有nspr的nss包

- 没有configure。只能提前设置好环境变量如下，进入nss目录执行`make nss_build_all`即可

  ```
  export BUILD_OPT=1
  export USE_64=1 #64位系统，32位不用设置
  #没有找到prefix之类的设置
  ```

- 中途报错缺少zlib.h，编译安装zlib后解决[参考](http://blog.csdn.net/xiaolixiaoyi/article/details/37767297)

- 安装结束后进入nss/tests执行`./all.sh`即可测试，注意测试之前设置如下环境变量

  ```
   export HOST=localhost 
   export DOMSUF=localdomain
  ```

  并且`vim /etc/hosts` 在127.0.0.1 后面改为 `localhost.localdomain`

  测试耗时较长(相当长)


## LuaJIT

[官方指导文档](http://luajit.org/install.html)

- `make` && `make install PREFIX=/home/opt/luajit205`

- 添加路径

- `gcc -o a a.c -I /home/opt/luajit205/include/luajit-2.0 -L /home/opt/luajit205/lib -lluajit-5.1` 编译举例，测试代码如下

  ```
  /* a.c */
  #include <stdio.h>
  #include <string.h>
  #include <lua.h>
  #include <lualib.h>
  #include <lauxlib.h>

  int main (void) {
      char buff[256];
      int error;
      lua_State *L = lua_open();
      luaL_openlibs(L);
    
      while (fgets(buff, sizeof(buff), stdin) != NULL) {
          error = luaL_loadbuffer(L, buff, strlen(buff), "line") ||
                  lua_pcall(L, 0, 0, 0);
          if (error) {
            fprintf(stderr, "%s", lua_tostring(L, -1));
            lua_pop(L, 1);
          }
      }
      lua_close(L);
      return 0;
  }
  ```




## Pcre2

[LFS指导](http://www.linuxfromscratch.org/blfs/view/svn/general/pcre2.html) 

- ```
  ./configure --prefix=/home/opt/pcre2-1023 --docdir=/home/opt/share/doc/pcre2-1023 --enable-unicode --enable-pcre2-16 --enable-pcre2-32 --enable-pcre2grep-libz --enable-pcre2grep-libbz2 --enable-pcre2test-libreadline --disable-static
  ```

- `make`  &&  `make install`

  - `./configure`过程中可能会报错缺少readline相关，`yast`安装`readline-devel`即可




## Libuv

[官方指导](https://github.com/libuv/libuv/blob/master/README.md)

- ```
  $ sh autogen.sh
  $ ./configure --prefix=/home/opt/libuv-1131
  $ make
  $ make check
  $ make install
  ```

- 代码测试

  ```
  /* test.cc */
  #include <stdlib.h>
  #include <stdio.h>
  #include <uv.h>

  int main()
  {
      uv_loop_t *loop = uv_loop_new();
      uv_run(loop, UV_RUN_DEFAULT);
      printf("hello world!\n");
      return 0;
  }
  ```

  ```
  g++ -c  test.cc -o test.o -I /home/opt/libuv-1131/include/
  g++ -o test test.o -L /home/opt/libuv-1131/lib/ -luv
  LD_LIBRARY_PATH=/home/opt/libuv-1131/lib/ ./test
  ```



## WolfSSL

[官方指导](https://www.wolfssl.com/wolfSSL/Docs-wolfssl-manual-2-building-wolfssl.html)

- 下载的是 wolfssl-3.12.0.zip 


  ```
  ./configure --prefix=/home/opt/wolfssl3120
  make
  ./testsuite/testsuite.test
  make install
  ```



## 附注

### GCC 5.2

1. 解压进入gcc5.2源码目录，执行如下脚本安装MPFR,GMP,MPC,ISL

   `./contrib/download_prerequisites`

2. 在源码路径之外新建一个文件夹并进入

3. 执行 `unset CPLUS_INCLUDE_PATH LIBRARY_PATH C_INCLUDE_PATH` 避免之后的头文件库文件找不到

4. ```
   ../gcc-5.2.0/configure --prefix=/usr \
   --enable-checking=release \
   --enable-languages=c,c++ \
   --disable-multilib \
   --enable-threads=posix
   ```

5. `make`

6. `make install`

**`make`期间的错误处理**

1. `pic/libiberty.a`文件出错

   把之前生成的该文件复制过来，覆盖掉此处的该文件

2. `vim ../gcc-5.2.0/libgcc/config/t-softfp` 

   106行把else和ifneq分为两行

   ```
   else
   ifneq ($(softfp_wrap_start),)
   ```

   113行在文件末尾加一行 `endif`

3. 很多宏没有定义

   ```
   vim /usr/include/sys/ptrace.h
   vim /usr/include/linux/fs.h
   vim /usr/include/linux/input.h
   ```

   如上几个文件包含了缺失的宏，可去其他系统把对应的定义复制过来
