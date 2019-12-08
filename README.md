# ssl-certs

A makefile for generating self signed ssl certificates for the current host with cfssl.

## Prerequisites

### cfssl

Unfortunately, at the time of writing, the latest packaged version of cfssl
(1.2) contains a bug that makes it impossible to create certificates with
hosts, so the software must be installed with Go.

Here is how I installed cfssl on Ubuntu 18.04.

```bash
$ sudo apt install golang
$ go get -u github.com/cloudflare/cfssl/cmd/cfssl
$ sudo cp ~/go/bin/cfssl /usr/local/bin/cfssl
$ go get -u github.com/cloudflare/cfssl/cmd/cfssljson
$ sudo cp ~/go/bin/cfssljson /usr/local/bin/cfssljson
```

### Fully qualified domain name

The command `hostname -f` should produce a fully qualified domain name.

If you are using '/etc/hosts' to provide your local hostname make sure the fully
qualified domain name comes first. e.g.

```
127.00.0.1     myhost.example.com myhost
```

If this is problematic simply hard code  the values in the Makefile. e.g.

```bash
# If necessary manually override: HOSTNAME, FQDM, and PREFIX.
# HOSTNAME=$(shell hostname)
HOSTNAME=myhost
# FQDN=$(shell hostname -f)
FQDN=myhost.example.com
# PREFIX=$(shell hostname -d | sed -e 's/\./-/g')
PREFIX=example-com
```

## Makefile

With `hostname -f` producing `myhost.example.com` The makefile will generate the following files:

* example-com-ca.pem
* example-com-ca.csr
* example-com-ca-key.pem
* example-com-intermediate-ca.pem
* example-com-intermediate-ca.csr
* example-com-intermediate-ca-key.pem
* example-com-myhost-haproxy.pem
* example-com-myhost-server.pem
* example-com-myhost-server-key.pem
* example-com-myhost-peer.pem
* example-com-myhost-peer-key.pem
* example-com-myhost-peer.pem
* example-com-myhost-peer-key.pem

The *haproxy* file is a certificate chain containing in this order:

* example-com-myhost-server.pem
* example-com-myhost-server-key.pem
* example-com-intermediate-ca.pem
* example-com-ca.pem

## Installation

The `make install` task installs the following files:

* /usr/share/ca-certificates/myhost.example.com (owner root, group root, mode 644)
    * example-com-ca.pem
    * example-com-intermediate-ca.pem
    * example-com-myhost-server.pem
    * example-com-myhost-peer.pem
    * example-com-myhost-peer.pem
* /etc/ssl/private (owner root, group ssl-cert, mode 640)
    * example-com-ca-key.pem
    * example-com-intermediate-ca-key.pem
    * example-com-myhost-haproxy.pem
    * example-com-myhost-server-key.pem
    * example-com-myhost-peer-key.pem
    * example-com-myhost-peer-key.pem

For ubuntu in will be necessary to add each file in `/etc/ca-certificates.conf`.

Then call:

```bash
$ sudo update-ca-certificates
```
