openssl ca -config openssl-ca-sign.cnf -policy signing_policy -extensions signing_req -out servercert.pem -infiles servercert.csr
