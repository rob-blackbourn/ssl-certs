LOCAL_FOLDER=$(HOME)/.keys
SYSTEM_CERT_FOLDER=/etc/ssl/certs
SYSTEM_KEY_FOLDER=/etc/ssl/private

# If necessary manually override: HOSTNAME, FQDM, and PREFIX.
HOSTNAME=$(shell hostname)
FQDN=$(shell hostname -f)
PREFIX=$(shell hostname -d | sed -e 's/\./-/g')

HOST_JSON=$(HOSTNAME).json

CA=$(PREFIX)-ca
CA_CRT=$(CA).pem
CA_CSR=$(CA).csr
CA_KEY=$(CA)-key.pem

INTERMEDIATE_CA=$(PREFIX)-intermediate-ca
INTERMEDIATE_CA_CRT=$(INTERMEDIATE_CA).pem
INTERMEDIATE_CA_CSR=$(INTERMEDIATE_CA).csr
INTERMEDIATE_CA_KEY=$(INTERMEDIATE_CA)-key.pem

HOST_SERVER=$(PREFIX)-$(HOSTNAME)-server
HOST_SERVER_CRT=$(HOST_SERVER).pem
HOST_SERVER_CSR=$(HOST_SERVER).csr
HOST_SERVER_KEY=$(HOST_SERVER)-key.pem

HOST_PEER=$(PREFIX)-$(HOSTNAME)-peer
HOST_PEER_CRT=$(HOST_PEER).pem
HOST_PEER_CSR=$(HOST_PEER).csr
HOST_PEER_KEY=$(HOST_PEER)-key.pem

HOST_CLIENT=$(PREFIX)-$(HOSTNAME)-client
HOST_CLIENT_CRT=$(HOST_CLIENT).pem
HOST_CLIENT_CSR=$(HOST_CLIENT).csr
HOST_CLIENT_KEY=$(HOST_CLIENT)-key.pem

HOST_HAPROXY_PEM=$(PREFIX)-$(HOSTNAME)-haproxy.pem

.PHONY: all

all: ca intermediate-ca $(HOSTNAME)
	echo done

.PHONY: ca intermediate-ca $(HOSTNAME)

ca: $(CA_CRT)
intermediate-ca: $(INTERMEDIATE_CA_CRT) $(INTERMEDIATE_CA_KEY)
$(HOSTNAME): $(HOST_SERVER_CRT) $(HOST_PEER_CRT) $(HOST_CLIENT_CRT) $(HOST_HAPROXY_PEM)

$(CA_CRT): ca.json
	cfssl gencert -initca ca.json | cfssljson -bare $(CA)

$(INTERMEDIATE_CA_CRT): intermediate-ca.json
	cfssl gencert -initca intermediate-ca.json | cfssljson -bare $(INTERMEDIATE_CA)

$(INTERMEDIATE_CA_KEY): $(INTERMEDIATE_CA_CRT) $(CA_CRT) cfssl.json $(INTERMEDIATE_CA_CSR)
	cfssl sign -ca $(CA_CRT) -ca-key $(CA_KEY) -config cfssl.json -profile intermediate-ca $(INTERMEDIATE_CA_CSR) | cfssljson -bare $(INTERMEDIATE_CA)

$(HOST_JSON): host.json.template
	sed -e "s/FQDN/$(FQDN)/g" < host.json.template > $(HOST_JSON)

$(HOST_SERVER_CRT): $(INTERMEDIATE_CA_CRT) $(INTERMEDIATE_CA_KEY) cfssl.json $(HOST_JSON)
	cfssl gencert -ca $(INTERMEDIATE_CA_CRT) -ca-key $(INTERMEDIATE_CA_KEY) -config cfssl.json -profile=server $(HOST_JSON) | cfssljson -bare $(HOST_SERVER)

$(HOST_PEER_CRT): $(INTERMEDIATE_CA_CRT) $(INTERMEDIATE_CA_KEY) cfssl.json $(HOST_JSON)
	cfssl gencert -ca $(INTERMEDIATE_CA_CRT) -ca-key $(INTERMEDIATE_CA_KEY) -config cfssl.json -profile=peer $(HOST_JSON) | cfssljson -bare $(HOST_PEER)

$(HOST_CLIENT_CRT): $(INTERMEDIATE_CA_CRT) $(INTERMEDIATE_CA_KEY) cfssl.json $(HOST_JSON)
	cfssl gencert -ca $(INTERMEDIATE_CA_CRT) -ca-key $(INTERMEDIATE_CA_KEY) -config cfssl.json -profile=client $(HOST_JSON) | cfssljson -bare $(HOST_CLIENT)

$(HOST_HAPROXY_PEM): $(CA_CRT) $(INTERMEDIATE_CA_CRT) $(HOST_SERVER_CRT) $(HOST_SERVER_KEY)
	cat $(HOST_SERVER_CRT) $(HOST_SERVER_KEY) $(INTERMEDIATE_CA_CRT) $(CA_CRT) > $(HOST_HAPROXY_PEM)

.PHONY: install install-ca install-intermediate-ca install-host

install: install-ca install-intermediate-ca install-host

install-ca: $(CA_CRT) $(CA_KEY)
	install -o root -m 644 $(CA_CRT) $(SYSTEM_CERT_FOLDER)/$(CA_CRT)
	install -o root -g ssl-cert -m 640 $(CA_CSR) $(SYSTEM_KEY_FOLDER)/$(CA_CSR)
	install -o root -g ssl-cert -m 640 $(CA_KEY) $(SYSTEM_KEY_FOLDER)/$(CA_KEY)

install-intermediate-ca: $(INTERMEDIATE_CA_CRT) $(INTERMEDIATE_CA_KEY)
	install -o root -m 644 $(INTERMEDIATE_CA_CRT) $(SYSTEM_CERT_FOLDER)/$(INTERMEDIATE_CA_CRT)
	install -o root -g ssl-cert -m 640 $(INTERMEDIATE_CA_CSR) $(SYSTEM_KEY_FOLDER)/$(INTERMEDIATE_CA_CSR)
	install -o root -g ssl-cert -m 640 $(INTERMEDIATE_CA_KEY) $(SYSTEM_KEY_FOLDER)/$(INTERMEDIATE_CA_KEY)

install-host: install-host-server install-host-peer install-host-client install-host-haproxy

.PHONY: install-host-server install-host-peer install-host-client install-host-haproxy

install-host-server: $(HOST_SERVER_CRT) $(HOST_SERVER_KEY)
	install -o root -m 644 $(HOST_SERVER_CRT) $(SYSTEM_CERT_FOLDER)/$(HOST_SERVER_CRT)
	install -o root -g ssl-cert -m 640 $(HOST_SERVER_KEY) $(SYSTEM_KEY_FOLDER)/$(HOST_SERVER_KEY)

install-host-peer: $(HOST_PEER_CRT) $(HOST_PEER_KEY)
	install -o root -m 644 $(HOST_PEER_CRT) $(SYSTEM_CERT_FOLDER)/$(HOST_PEER_CRT)
	install -o root -g ssl-cert -m 640 $(HOST_PEER_KEY) $(SYSTEM_KEY_FOLDER)/$(HOST_PEER_KEY)

install-host-client: $(HOST_CLIENT_CRT) $(HOST_CLIENT_KEY)
	install -o root -m 644 $(HOST_CLIENT_CRT) $(SYSTEM_CERT_FOLDER)/$(HOST_CLIENT_CRT)
	install -o root -g ssl-cert -m 640 $(HOST_CLIENT_KEY) $(SYSTEM_KEY_FOLDER)/$(HOST_CLIENT_KEY)

install-host-haproxy: $(HOST_HAPROXY_PEM)
	install -o root -m 640 $(HOST_HAPROXY_PEM) $(SYSTEM_KEY_FOLDER)/$(HOST_HAPROXY_PEM)

.PHONY: uninstall uninstall-ca uninstall-intermediate-ca uninstall-beast

uninstall: uninstall-ca uninstall-intermediate-ca uninstall-beast

uninstall-ca:
	rm $(SYSTEM_CERT_FOLDER)/$(CA_CRT)
	rm $(SYSTEM_KEY_FOLDER)/$(CA_KEY)

uninstall-intermediate-ca:
	rm $(SYSTEM_CERT_FOLDER)/$(INTERMEDIATE_CA_CRT)
	rm $(SYSTEM_KEY_FOLDER)/$(INTERMEDIATE_CA_KEY)

uninstall-beast:
	rm $(SYSTEM_CERT_FOLDER)/$(HOST_SERVER_CRT)
	rm $(SYSTEM_KEY_FOLDER)/$(HOST_SERVER_KEY)
	rm $(SYSTEM_CERT_FOLDER)/$(HOST_PEER_CRT)
	rm $(SYSTEM_KEY_FOLDER)/$(HOST_PEER_KEY)
	rm $(SYSTEM_CERT_FOLDER)/$(HOST_CLIENT_CRT)
	rm $(SYSTEM_KEY_FOLDER)/$(HOST_CLIENT_KEY)

install-local:
	mkdir -p $(LOCAL_FOLDER)
	cp $(HOST_SERVER_CRT) $(LOCAL_FOLDER)/server.crt
	cp $(HOST_SERVER_KEY) $(LOCAL_FOLDER)/server.key

.PHONY: clean

clean:
	rm -f $(CA_CRT)
	rm -f $(CA_KEY)
	rm -f $(CA_CSR)
	rm -f $(INTERMEDIATE_CA_CRT)
	rm -f $(INTERMEDIATE_CA_KEY)
	rm -f $(INTERMEDIATE_CA_CSR)
	rm -f $(HOST_SERVER_CRT)
	rm -f $(HOST_SERVER_KEY)
	rm -f $(HOST_SERVER_CSR)
	rm -f $(HOST_PEER_CRT)
	rm -f $(HOST_PEER_KEY)
	rm -f $(HOST_PEER_CSR)
	rm -f $(HOST_CLIENT_CRT)
	rm -f $(HOST_CLIENT_KEY)
	rm -f $(HOST_CLIENT_CSR)
	rm -f $(HOST_HAPROXY_PEM)
	rm -f $(HOST_JSON)
