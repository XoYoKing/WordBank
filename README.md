# WordBank
![Language](http://img.shields.io/badge/Language-Objective--C-brightgreen.svg?style=flat) [![CSDN](https://img.shields.io/badge/CSDN-Peter__Huang0623-orange.svg)](https://blog.csdn.net/Peter_Huang0623)  [![e-mail](https://img.shields.io/badge/E--mail-huangchao0623%40126.com-blue.svg)](huangchao0623@126.com)

<div align=center> <img src='https://github.com/Peter-Huang0623/WordBank/blob/master/README_Pics/1-1242-2208.jpg' width='30%' height='30%'> <img src='https://github.com/Peter-Huang0623/WordBank/blob/master/README_Pics/1242-2208.jpg' width='30%' height='30%'>  <img src='https://github.com/Peter-Huang0623/WordBank/blob/master/README_Pics/2-1242-2208.jpg' width='30%' height='30%'></div>

## 1、使用到的第三方框架

* JPNavigationController
* Masonry
* JPVideoPlayer
* BmobSDK
* AFNetworking
* SDWebImage
* SCLAlertView-Objective-C
* VBFPopFlatButton

**依赖管理：**
本项目使用cocoapods,当前目录文件下在终端中输入`pod install`即可导入需要安装的第三方库。
## 2、翻译功能的实现
本项目使用[百度翻译API](http://api.fanyi.baidu.com/api/trans/product/apidoc)实现中日、日中互翻。

**使用步骤：**
1. 登录[百度翻译开放平台](http://api.fanyi.baidu.com/api/trans/product/index)进行注册，得到APPID和密钥。
2. 对代翻译内容作UTF-8编码，对其余字段作URL encode。
3. 对请求参数进行字符串拼接（appid+query+salt+密钥）
4. 对生成的字符串作MD5加密。
5. 对待翻译文本作 URL encode。
6. GET or POST

## 3、Bmob后端云
本项目使用的数据库以及短信验证码服务均使用Bmob后端云实现，通过集成Bmob SDK,可以快速完成数据库的部署，大大缩短开发周期。