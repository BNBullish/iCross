# iCross

## 概念

### cross-tool

https://github.com/crosstool-ng/crosstool-ng

cross-tool 是一个交叉编译工具，通过配置，可以建立起满足需求的编译环境。

### 可执行文件的依赖库

本项目关注`linux`下的依赖库的研究。

一个可执行程序，通常会使用其他软件的一部分功能，以加载动态链接库的形式，这样就造成了依赖。

以`ssl`为例。

很多网络程序需要在通信过程中需要`ssl`的加密功能，就会依赖于`/usr/lib/libssl.so` , `/usr/lib/libcrypto.so` 等库文件实现的加密/解密算法。脱离了`ssl`库，它们就不能运行。

### glibc

`glibc` 是 linux下最常用的c库。以glibc为例。它沟通内核与应用程序，提供诸多标准的c库函数，以及`GNU`扩展函数，或扩展的函数语义。除非处于特别目的，不使用c库，可以不依赖于`glibc`。一般的程序必须要依赖于`glibc`。

### ABI 兼容

有别于`API`兼容。

`API`定义了库和使用者之间的接口，只要某个系统提供/支持该API，则使用了该API的代码就可以在该系统中编译。

而`ABI`是在编译好的目标代码/可执行文件的概念上实现的接口。ABI兼容意味着编译好的二进制程序，可以直接在目标环境中运行。

- 例1

  ```c
  FILE * fopen(const char * path, const char * mode);
  // ..... 
  int fclose( FILE *fp );
  ```

  `windows`系统和`linux`系统都支持该API，因此使用了该API的代码，可以在`windows`下编译，也可以在`linux`下编译。此为API兼容。

  然而`windows`下编译出来的程序格式为`PE`(Portable Executable File Format) 格式，`linux`下编译出的程序为`ELF`(Executable and Linkable Format) 格式。PE不可以直接在linux下运行，ELF也不可以直接在windows下运行。可以视为ABI不兼容。


- 例2

  glibc为了保持对老的代码的兼容，给发生变动的函数，打上了版本标记。

  假设现在有两个版本的glibc: glibc 2.X > glibc 2.Y。

  glibc提供的某个函数f,在这两个版本中发生了变动，在glibc 2.X 中的f版本为X，在glibc版本中的f版本为Y。

  依赖于glibc 2.X 编译的程序，使用了X版本的f函数。该程序在glibc2.Y的环境中，则不能运行，因为glibc2.Y没有提供X版本的f函数。



为了实现ABI兼容，linux下有个LSB。然而并不是所有的系统/库都能完美支持LSB。



### 向后兼容（backward）和向前兼容（forward）

通常的库，会支持backward的兼容，forwar的兼容则难以保证。

比如在老的glibc编译的库，可以在新的glibc下运行。反之则不能。



### C语言和C++语言的标准

c语言和c++语言在演化，为了功能扩充和强化，每隔数年会制定新的标准。目前常用的c的标准有c89，c99；c++的标准有c++03,c++11。



## 需求

现在需要以二进制方式发布我们自己的软件。为了让我们的软件可以在各种linux版本上运行，我们需要让自己的软件具有良好的ABI兼容性。

常规的编译环境不能满足我们的需求，因此借助cross-tool建立满足需求的编译环境，**但是如果有更好的方案，不限于使用cross-tool**



说明，以下的目标不一定能完美实现，但是需要尽量实现。

尽量的含义举例：不能满足c++03的要求，则放宽范围为满足c89的要求。不能在RHEL4.0+运行，放宽范围为RHEL5.0+运行，等等。



## 小目标：c99,c++03,RHEL6+

功能，构造一个编译环境

- 编译环境支持c编译器，以c89为最低标准
- 编译环境支持c++编译器，以c++03为最低标准
- 编译出的程序，以RHEL为标准，最低可以在RHEL6.0上运行



## 中目标： c99, c++11, RHEL5+

功能，构造一个编译环境

- 编译环境支持c编译器，以c99为最低标准
- 编译环境支持c++编译器，以c++11为最低标准
- 编译出的程序，以RHEL为标准，最低可以在RHEL5.0上运行
- 支持的软件/库列表，包括不限于
  - nss
  - luajit
  - pcre2
  - libuv
  - woflssl



## 大目标：c99, c++11, all Linux dist

功能，构造一个编译环境

- 满足**中目标** 的需求
- 编译出的程序，可以在几乎所有以linux2.6.x+内核的主流linux发行版运行
  - 可能的发行版和版本
    - RHEL 5.0+ 
    - Debian 7.0+ 
    - Suse  10+
    - Ubuntu 12+


