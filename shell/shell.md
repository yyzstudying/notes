## shell

**1 $0** 为执行的文件名**

```shell
echo "执行的文件名：$0";
```

**2. 文件测试运算符**

```shell
if [ -d $file ] #是否为目录
if [ -e $file ] #文件是否存在
```

**3. find使用正则查找文件夹并删除**

```shell
find 路径  -regex  "包含正则的查找对象" -type d |xargs rm -rf
```

**4. $?   >>>> 上一条指令的返回结果**

~~~shell
if [  $? -eq 0 ] #执行成功
~~~

**5. 将标准错误输出重定向到标准输出（将脚本输出写入文件）**

~~~shell
. ./$PATH/shName.sh>> $FILE 2>&1
~~~

**6.往文件中追加内容**

```shell
 echo "内容" >> 文件
```

**7. 数组**

```shell
arr=("a" "b" "c") 
for var in ${arr[@]} 
do
   echo $var 
done
```

**8. 读取一行文件类容**

```shell
while read line
do
	 echo $line"
done < fileName.txt
```

**9. 读取xml中component的version字段**

```xml
<platform name="RCOS" >
	<version>9.0.0</version>
	<components>
		<component name="rcos-rcdc" version="0.0.1" platform-type="ALL" reboot-when-upgrade="NOT"/>
   </components>
</platform>
```

```shell
function getVersion(){
    version=$(xmllint --xpath "string(//platform/components/component[@name='$1']/@version)" $version_file)
    echo $version
}

```

**10 .版本号排序**

  ~~~shell
 ls | sort -V
  ~~~

**11.获取文件中的键值对**

```shell
# 获取文件中的键值对
while read line
do
	key=`echo $line | cut -d "=" -sf 1`
	value=`echo $line | cut -d "=" -sf 2-`
	echo $key : $value
done < $FILE
```

**12.获取版本号**

```shell
ls | grep -E -o  "([0-9])+\.([0-9])+\.([0-9])+"
```

**13.替换字符串**

```shell
sed "s/要替换的文本/替换为/g"  
# ls | sed "s/-1.0.0-dhasufaf.jar//g"
```





**rpm打包spec文件**

```shell
# 这个区域定义的Name、Version这些字段对应的值可以在后面
# 通过%{name},%{version}这样的方式来引用，类似于C语言中的宏
 
# Name制定了软件的名称
Name:       a
# 软件版本
Version:    1.1
# 释出号，也就是第几次制作rpm
Release:    1%{?dist}
# 软件的介绍，必须设置，最好不要超过50个字符
Summary:    Nginx from WangYing
 
# 软件的分组，可以通过/usr/share/doc/rpm-4.8.0/GROUPS文件中选择，也可以
# 在相应的分类下，自己创建一个新的类型，例如这里的Server
Group:      Application/Server
# 许可证类型
License:    GPL
# 软件的源站
URL:        http://nginx.org
# 制作rpm包的人员信息
Packager:   WangYing <justlinux2010@gmail.com>
# 源码包的名称，在%_topdir/SOURCE下，如果有多个源码包的话，可以通过
# Source1、Source2这样的字段来指定其他的源码包
Source0:    %{name}-%{version}.tar.gz
# BuildRoot指定了make install的测试安装目录，通过这个目录我们可以观察
# 生成了哪些文件，方便些files区域。如果在files区域中写的一些文件报
# 不存在的错误，可以查看%_topdir/BUILDROOT目录来检查有哪些文件。
BuildRoot:  %_topdir/BUILDROOT
# 指定安装的路径
Prefix:     /usr/local/nginx-1.5.2
 
# 制作过程需要的工具或软件包
BuildRequires:  gcc,make
# 安装时依赖的软件包
Requires: pcre,pcre-devel,openssl
 
# 软件的描述，这个可以尽情地写
%description
Nginx is a http server
 
# %prep指定了在编译软件包之前的准备工作，这里的
# setup宏的作用是静默模式解压并切换到源码目录中，
# 当然你也可以使用tar命令来解压
%prep
%setup -q
 
# 编译阶段，和直接编译源代码类似，具体的操作或指定的一些参数由configure文件决定。
%build
CFLAGS="-pipe -O2 -g -W -Wall -Wpointer-arith -Wno-unused-parameter -Werror" ./configure --prefix=%{prefix}
# make后面的意思是：如果是多处理器，则并行编译
make %{?_smp_mflags}
 
# 安装阶段
%install
# 先删除原来的测试安装的，只有在制作失败了%{buildroot}目录才会有内容，
# 如果成功的话，目录下会被清除。
# %{buildroot}指向的目录不是BuildRoot（%_topdir/BUILDROOT）指定的目录，
# 而是该目录下名称与生成的rpm包名称相同的子目录。例如我的是
# /usr/src/redhat/BUILDROOT/nginx-1.5.2-1.el6.x86_64
rm -rf %{buildroot}
# 指定安装目录，注意不是真实的安装目录，是在制作rpm包的时候指定的
# 安装目录，如果不指定的话，默认就会安装到configure命令中指定的prefix路径，
# 所以这里一定要指定DESTDIR
make install DESTDIR=%{buildroot}
 
# 安装前执行的脚本，语法和shell脚本的语法相同
%pre
 
# 安装后执行的脚本
%post
 
# 卸载前执行的脚本，我这里的做的事情是在卸载前将nginx服务器停掉
%preun
   
# 卸载完成后执行的脚本
%postun
    rm -rf %{prefix}
 
# 清理阶段，在制作完成后删除安装的内容
%clean
rm -rf %{buildroot}
 
#指定要包含的文件
%files
/root/Centos-7.repo
#设置默认权限，如果没有指定，则继承默认的权限
%defattr  (-,root,root,0755)
%{prefix}

```





