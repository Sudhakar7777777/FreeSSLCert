openssl req -x509 -config openssl-ca.cnf -newkey rsa:4096 -days 3650 -sha256 -nodes -out cacert.pem -outform PEM
