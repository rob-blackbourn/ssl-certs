# ssl-certs

Configuration for making ssl certificates with cfssl.

### cfssl

Unfortunately, at the time of writing, the latest packaged version of cfssl
(1.2) contains a bug that makes it impossible to create certificates with
hosts, so the software must be installed with Go.

Here si how I install cfssl on Ubuntu 18.04.

```bash
$ sudo apt install golang
$ go get -u github.com/cloudflare/cfssl/cmd/cfssl
$ sudo cp ~/go/bin/cfssl /usr/local/bin/cfssl
$ go get -u github.com/cloudflare/cfssl/cmd/cfssljson
$ sudo cp ~/go/bin/cfssljson /usr/local/bin/cfssljson
```

## Usage

### /etc/hosts

If you are using '/etc/hosts' to provide your local hostname make sure the fully
qualified domain name comes first. e.g.

### Makefile

With the `PREFIX=jetblack-net-` The makefile will generate the following files:

* jetblack-net-ca.pem
* jetblack-net-ca.csr
* jetblack-net-ca-key.pem
* jetblack-net-intermediate-ca.pem
* jetblack-net-intermediate-ca.csr
* jetblack-net-intermediate-ca-key.pem
* jetblack-net-beast-haproxy.pem
* jetblack-net-beast-server.pem
* jetblack-net-beast-server-key.pem
* jetblack-net-beast-peer.pem
* jetblack-net-beast-peer-key.pem
* jetblack-net-beast-peer.pem
* jetblack-net-beast-peer-key.pem

The *haproxy* file is a certificate chain containing in this order:

* jetblack-net-beast-server.pem
* jetblack-net-beast-server-key.pem
* jetblack-net-intermediate-ca.pem
* jetblack-net-ca.pem

## Installation

The `make install` task installs the following files:

* /etc/ssl/certs (owner root, group root, mode 644)
    * jetblack-net-ca.pem
    * jetblack-net-intermediate-ca.pem
    * jetblack-net-beast-server.pem
    * jetblack-net-beast-peer.pem
    * jetblack-net-beast-peer.pem
* /etc/ssl/private (owner root, group ssl-cert, mode 640)
    * jetblack-net-ca-key.pem
    * jetblack-net-intermediate-ca-key.pem
    * jetblack-net-beast-haproxy.pem
    * jetblack-net-beast-server-key.pem
    * jetblack-net-beast-peer-key.pem
    * jetblack-net-beast-peer-key.pem
