LOCAL_CERT_FOLDER=$(HOME)/.keys
LOCAL_KEY_FOLDER=$(HOME)/.keys
SYSTEM_CERT_FOLDER=/etc/ssl/certs
SYSTEM_KEY_FOLDER=/etc/ssl/private
PREFIX=jetblack-net-

.PHONY: all

all: ca intermediate-ca beast
	echo done

.PHONY: ca intermediate-ca beast

ca: $(PREFIX)ca.pem
intermediate-ca: $(PREFIX)intermediate-ca.pem $(PREFIX)intermediate-ca-key.pem
beast: $(PREFIX)beast-server.pem $(PREFIX)beast-peer.pem $(PREFIX)beast-client.pem

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

.PHONY: install install-ca install-intermediate-ca install-beast

install: install-ca install-intermediate-ca install-beast

install-ca:
	install -o root -m 644 $(PREFIX)ca.pem $(SYSTEM_CERT_FOLDER)/$(PREFIX)ca.pem
	install -o root -g ssl-cert -m 640 $(PREFIX)ca.pem $(SYSTEM_KEY_FOLDER)/$(PREFIX)ca-key.pem

install-intermediate-ca:
	install -o root -m 644 $(PREFIX)intermediate-ca.pem $(SYSTEM_CERT_FOLDER)/$(PREFIX)intermediate-ca.pem
	install -o root -g ssl-cert -m 640 $(PREFIX)intermediate-ca.pem $(SYSTEM_KEY_FOLDER)/$(PREFIX)intermediate-ca-key.pem

install-beast:
	install -o root -m 644 $(PREFIX)beast-server.pem $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-server.pem
	install -o root -g ssl-cert -m 640 $(PREFIX)beast-server-key.pem $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-server-key.pem
	install -o root -m 644 $(PREFIX)beast-peer.pem $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-peer.pem
	install -o root -g ssl-cert -m 640 $(PREFIX)beast-peer-key.pem $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-peer-key.pem
	install -o root -m 644 $(PREFIX)beast-client.pem $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-client.pem
	install -o root -g ssl-cert -m 640 $(PREFIX)beast-client-key.pem $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-client-key.pem

.PHONY: uninstall uninstall-ca uninstall-intermediate-ca uninstall-beast

uninstall: uninstall-ca uninstall-intermediate-ca uninstall-beast

uninstall-ca:
	rm $(SYSTEM_CERT_FOLDER)/$(PREFIX)ca.pem
	rm $(SYSTEM_KEY_FOLDER)/$(PREFIX)ca-key.pem

uninstall-intermediate-ca:
	rm $(SYSTEM_CERT_FOLDER)/$(PREFIX)intermediate-ca.pem
	rm $(SYSTEM_KEY_FOLDER)/$(PREFIX)intermediate-ca-key.pem

uninstall-beast:
	rm $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-server.pem
	rm $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-server-key.pem
	rm $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-peer.pem
	rm $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-peer-key.pem
	rm $(SYSTEM_CERT_FOLDER)/$(PREFIX)beast-client.pem
	rm $(SYSTEM_KEY_FOLDER)/$(PREFIX)beast-client-key.pem

install-local:
	mkdir -p $(LOCAL_CERT_FOLDER)
	cp $(PREFIX)beast-server.pem $(LOCAL_CERT_FOLDER)/server.pem
	mkdir -p $(LOCAL_KEY_FOLDER)
	cp $(PREFIX)beast-server-key.pem $(LOCAL_KEY_FOLDER)/server-key.pem

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
