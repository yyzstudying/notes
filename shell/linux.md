**1.常用命令**

1. ls

   * **-h **：文件大小显示格式化
   * -d ：查看目录本身

2. mkdir

   - -p ：递归创建

3. cp

   - -p ：保留文件属性
   - -r ：复制目录

4. cat

   - -n ：同时显示行号

5. more、less

   - 空格 ：下一页
   - Enter ：下一行
   - q 、Q ：退出

6. tail

   - -n ： 显示行数
   - -f  ：动态显示 

7. chmod

   - -R ：递归修改权限

8. find

   - -name ：按名称搜索

   - \* ： 匹配任意字符
   - ？：匹配一个字符
     - find  /etc -name \*init\*
     - find  /etc -name ini???

9. locate

10. 网络命令

    1. ping
    2. ifconfig
    3. netstat  -tlun

**2.文件压缩与解压缩**

1. gz（只能压缩文件且不保留源文件）

   - 压缩：gzip + 文件名
   - 解压缩：gunzip + 文件名

2. .tar

   - 压缩：tar -cvf  + 文件名 + 目标文件[夹]  
     - 如：tar -cvf xxx.tar xxx
   - 解压：tar - xvf xxx.tar

3. .tar.gz

   - 压缩
     - **tar -zcvf  xxx.tar.gz  xxx**
     - 在.tar文件上再进行gzip操作

   - 解压
     - **tar -zxvf xxx.tar.gz**

4. zip

   -  压缩
     - zip xxx.zip xxx （文件）
     - zip -r xxx.zip xxx（文件夹）
   - 解压
     - unzip xxx.zip

5. bzip2（压缩比很大，适合大文件）

   - -k 保留源文件

6. tar.bz2

   - tar -cjf xxx.tar.bz2 xxx 

   - tar -xjf xxx.tar.bz2

     

**3.vim**

1. 基本命令

   ![1-1](I:\notes\img\linux\1-1.png)

   ![1-2](I:\notes\img\linux\1-2.png)

2. h 