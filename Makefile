LOCAL_CERT_FOLDER=$(HOME)/.keys
LOCAL_KEY_FOLDER=$(HOME)/.keys
SYSTEM_CERT_FOLDER=/etc/ssl/certs
SYSTEM_KEY_FOLDER=/etc/ssl/private
PREFIX=jetblack-net-

.PHONY: all

all: $(PREFIX)ca.pem $(PREFIX)intermediate-ca.pem $(PREFIX)intermediate-ca-key.pem $(PREFIX)beast-server.pem $(PREFIX)beast-peer.pem $(PREFIX)beast-client.pem
	echo done

.PHONY: ca intermediate-ca

ca: $(PREFIX)ca.pem
intermediate-ca: $(PREFIX)intermediate-ca.pem $(PREFIX)intermediate-ca-key.pem

$(PREFIX)ca.pem: ca.json
	cfssl gencert -initca ca.json | cfssljson -bare $(PREFIX)ca

$(PREFIX)intermediate-ca.pem: intermediate-ca.json
	cfssl gencert -initca intermediate-ca.json | cfssljson -bare $(PREFIX)intermediate-ca

$(PREFIX)intermediate-ca-key.pem: $(PREFIX)intermediate-ca.pem $(PREFIX)ca.pem cfssl.json $(PREFIX)intermediate-ca.csr
	cfssl sign -ca $(PREFIX)ca.pem -ca-key $(PREFIX)ca-key.pem -config cfssl.json -profile intermediate-ca $(PREFIX)intermediate-ca.csr | cfssljson -bare $(PREFIX)intermediate-ca

$(PREFIX)beast-server.pem: $(PREFIX)intermediate-ca.pem $(PREFIX)intermediate-ca-key.pem cfssl.json beast.json
	cfssl gencert -ca $(PREFIX)intermediate-ca.pem -ca-key $(PREFIX)intermediate-ca-key.pem -config cfssl.json -profile=server beast.json | cfssljson -bare $(PREFIX)beast-server

$(PREFIX)beast-peer.pem: $(PREFIX)intermediate-ca.pem $(PREFIX)intermediate-ca-key.pem cfssl.json beast.json
	cfssl gencert -ca $(PREFIX)intermediate-ca.pem -ca-key $(PREFIX)intermediate-ca-key.pem -config cfssl.json -profile=peer beast.json | cfssljson -bare $(PREFIX)beast-peer

$(PREFIX)beast-client.pem: $(PREFIX)intermediate-ca.pem $(PREFIX)intermediate-ca-key.pem cfssl.json beast.json
	cfssl gencert -ca $(PREFIX)intermediate-ca.pem -ca-key $(PREFIX)intermediate-ca-key.pem -config cfssl.json -profile=client beast.json | cfssljson -bare $(PREFIX)beast-client

.PHONY: install

install:
	install -o root -m 644 $(PREFIX)beast-server.pem $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-server.pem
	install -o root -g ssl-cert -m 640 $(PREFIX)beast-server-key.pem $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-server-key.pem

.PHONY: uninstall

uninstall:
	rm $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-server.pem
	rm $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-server-key.pem

.PHONY: clean

clean:
	rm -f $(PREFIX)ca.pem
	rm -f $(PREFIX)ca-key.pem
	rm -f $(PREFIX)ca.csr
	rm -f $(PREFIX)intermediate-ca.pem
	rm -f $(PREFIX)intermediate-ca-key.pem
	rm -f $(PREFIX)intermediate-ca.csr
	rm -f $(PREFIX)beast-server.pem
	rm -f $(PREFIX)beast-server-key.pem
	rm -f $(PREFIX)beast-server.csr
	rm -f $(PREFIX)beast-peer.pem
	rm -f $(PREFIX)beast-peer-key.pem
	rm -f $(PREFIX)beast-peer.csr
	rm -f $(PREFIX)beast-client.pem
	rm -f $(PREFIX)beast-client-key.pem
	rm -f $(PREFIX)beast-client.csr
