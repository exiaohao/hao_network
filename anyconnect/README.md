# Install Anyconnect
## Requirements
### Ocserv server
```
ftp://ftp.infradead.org/pub/ocserv
```

### Dependents
#### Ubuntu
```bash
apt-get install -y build-essential pkg-config libgnutls28-dev libreadline-dev libseccomp-dev libwrap0-dev libnl-nf-3-dev liblz4-dev libev-dev autogen libev-dev gnutls-bin
```

#### CentOS
```bash
yum install epel-release -y
yum install ocserv -y
```

## Configuration

### Get a free certificate from authority
- https://console.cloud.tencent.com/ssl

### Build your CA certificate & key

file `ca.tmpl`
```
cn = "Your CA name" 
organization = "Your fancy name" 
serial = 1 
expiration_days = 3650
ca 
signing_key 
cert_signing_key 
crl_signing_key
```

Generate CA certificate & key
```bash
certtool --generate-privkey --outfile ca-key.pem
certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem
```

file `server.tmpl`
```
cn = "Your hostname or IP" 
organization = "Your fancy name" 
expiration_days = 3650
signing_key 
encryption_key
tls_www_server
```

Generate server certificate & key
```
certtool --generate-privkey --outfile server-key.pem
certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem
```

Save certificates and keys to `/etc/ocserv/ssl` (Or other path what you have configured)

### Install ocserv

Download newest ocserv package from
```
ftp://ftp.infradead.org/pub/ocserv
```

CentOS
```
yum install ocserv -y
```
