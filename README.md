# ssl-certs

Configuration for making ssl certificates with cfssl.

## Usage

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
