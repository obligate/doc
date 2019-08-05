## 生成tomcat ssl 证书 -- keystore
+ 1.从https://certs.godaddy.com/repository/下载根证书【gdroot-g2.crt】和中间证书【gdig2.crt】
	+ gdroot-g2.crt
	+ gdig2.crt.pem
	+ 中级证书和根证书合并成一个ca.crt证书
```
cat gdig2.crt.pem gdroot-g2.crt  > ca.crt
```
+ 2.从godday下载apache证书，一般有两个，一个自己的证书【随机字符串表示】，一个GoDaddy证书捆绑包，G2与G1交叉认证,包含根证书
	+ 406ba1f2052a1544.crt
	+ gd_bundle-g2-g1.crt
	+ 证书合成一个自己域名的证书
```
cat  406ba1f2052a1544.crt  gd_bundle-g2-g1.crt > peter.net.crt
```
+ 3.提取私钥文件
	+ 从iis服务器导出的pfx中提取key,之前证书第一次在iis被使用，所以只能从iis导出pfx(密码：1)，自己转换成key
```
openssl pkcs12 -in peter.net.pfx -nocerts -nodes -out peter.net.key
```
+ 4.转换成p12格式，是为了方便以后其他项目使用，例如nginx/CDN等，通用的格式,通常包含保护密码，2进制方式
```
openssl pkcs12 -export -in peter.net.crt -inkey peter.net.key -out peter.net.p12 -name peter_net -chain -CAfile ca.crt
```
注：（运行命令后，请按照提示输入一个你可以记得住的密码,密码qwe123)
+ 5.生成keystore文件，使用Java自带的Keytool工具
```
keytool -importkeystore -deststorepass qwe123 -destkeypass qwe123 -destkeystore peter.net.keystore -srckeystore peter.net.p12 -srcstoretype PKCS12 -srcstorepass qwe123 -alias peter_net
```
 + 也可以keystore转成成p12格式,通过p12导出证书和私钥
```
keytool -importkeystore -srckeystore peter.net.keystore -destkeystore peter.net.p12 -deststoretype PKCS12 -srcalias peter_net -deststorepass qwe123 -destkeypass qwe123
openssl pkcs12 -in peter.net.p12  -nokeys -out peter.net.pem
openssl pkcs12 -in peter.net.p12  -nodes -nocerts -out peter.net.key.pem
```
+ 6. 配置tomcat
```
<Connector port="443" protocol="org.apache.coyote.http11.Http11Protocol" 
               maxThreads="150" SSLEnabled="true" scheme="https" secure="true" 
               clientAuth="false" sslProtocol="TLS"  keystoreFile="/root/.ssh/peter.net.keystore" keystorePass="qwe123"/> 
```
```
    keystoreFile="/root/.ssh/peter.net.keystore"
    keystorePass="qwe123"
    SSLCertificateFile="/mnt/prod/tomcats/peter-net.crt"
```


## 命令：
```
 openssl x509 -in peter-net.crt  -noout -dates       # 查询过期时间
 curl -vX POST https://sms.peter.net:18443/imn/mo/   # 检测证书是否过期
 ```