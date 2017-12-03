# 安装
先配置好软件源，除了软件源之外，其余文件均为本地调用。
```bash
# in root
apt update & apt upgrade
cd ssr-onekey
chmod +x ssr-onekey.sh
./ssr-onekey
安装完成后，会提示输入密码和端口号。
```


# 一些必要的信息
安装路径：/home/ssr/
配置文件路径：/home/ssr/mudb.json

添加用户：ssr adduser
删除用户：ssr deluser
启动SSR：ssr start
停止SSR：ssr stop
重启SSR：ssr restart
卸载SSR：ssr uninstall

# 参考配置文件


## 开启SSR（不再兼容SS）
```json
[
    {
        "d": 0,
        "enable": 1,
        "method": "aes-256-cfb",
        "obfs": "http_simple",
        "passwd": "ssrPASSWORD",
        "port": 8989,
        "protocol": "auth_sha1_v4",
        "transfer_enable": 9007199254740992,
        "u": 183319,
        "user": "12345"
    }
]

```
# 参考
https://github.com/91yun/shadowsocks_install

