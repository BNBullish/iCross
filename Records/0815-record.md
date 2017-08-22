## 环境搭建

1. 在 SUSE 10.1 64bit 上，提前使用 yast 图形工具，从光盘安装了 gcc gcc-c++ kernel-source zlib-devel  readline-devel 等
2. 依次源码安装如下工具到 /usr 目录下,可参考LFS8.0手册与网上其他资料，报错信息参考之前的记录解决
   - binutils
   - gcc
   - m4
   - autoconf
   - automake
   - make

## 构建NSS

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


## 编译安装LuaJIT

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




## 编译安装 pcre2

[LFS指导](http://www.linuxfromscratch.org/blfs/view/svn/general/pcre2.html) 

- ```
  ./configure --prefix=/home/opt/pcre2-1023 --docdir=/home/opt/share/doc/pcre2-1023 --enable-unicode --enable-pcre2-16 --enable-pcre2-32 --enable-pcre2grep-libz --enable-pcre2grep-libbz2 --enable-pcre2test-libreadline --disable-static
  ```

- `make`  &&  `make install`

  - `./configure`过程中可能会报错缺少readline相关，`yast`安装`readline-devel`即可




## 编译安装libuv

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



## 编译安装wolfssl

[官方指导](https://www.wolfssl.com/wolfSSL/Docs-wolfssl-manual-2-building-wolfssl.html)

- 下载的是 wolfssl-3.12.0.zip 


- ```
  ./configure --prefix=/home/opt/wolfssl3120
  make
  ./testsuite/testsuite.test
  make install
  ```

