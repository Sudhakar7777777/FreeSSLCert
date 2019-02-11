# FreeSSLCert

How to create self signed certificate for non-production use cases?

Best way to create self signed certificate that works in most browsers is to create your own certification authority and use it to sign the certificates.

This is a two-step process. First you set up your CA, and then you sign an end entity certificate (a.k.a server or user). Both of the two commands elide the two steps into one. And both assume you have a an OpenSSL configuration file already setup for both CAs and Server (end entity) certificates.

Steps:
1. Create your own CA authority (i.e., become a CA)
2. Create a certificate signing request (CSR) for the server
3. Sign the server's CSR with your CA key
4. Install the server certificate on the server
5. Install the CA certificate on the client

Step 1 - Setup your own CA Authority.

1. Create a configuration file for creating your CA.  See attached file: openssl-ca.cnf for sample configurations.
	- Set CA to true in Basic Constraints (it should also be marked as critical)
	- key usage is keyCertSign and crlSign (if you are using CRLs)
	- Subject Key Identifier (SKI) is the same as the Authority Key Identifier (AKI)

The defaults save you the time from entering the same information while experimenting with configuration file and command options.  When you run the command, accept the defaults as is.

Change the ca_distinguished_name section with your custom name, FQDN, etc.

2. Run the command create-ca-cert.sh
	- Certification expiration is set for 10 years as its a test one.  Change as desired.
	- Adjust configuration if anything is desired, but this should work in general.

After the command executes, cacert.pem will be your certificate for CA operations, and cakey.pem will be the private key. Recall the private key does not have a password or passphrase.

3. Run the command print-ca-cert.sh to review the ca certificate.

4. Run the command print-ca-purpose.sh to review the ca certificate's purpose.

Congrats, you have successfully created your own CA.

Step 2 - Create a CSR for the server.

1. Create a configuration file for server request.  Review the file openssl-server.cnf and make desired adjustments.  Setup desired FQDN on alternate_names section for your server/site.

2. Run the command create-server-cert.sh

After this command executes, you will have a request in servercert.csr and a private key in serverkey.pem.

3. Run the command print-server-cert.sh to review the server certificate details.

Step 3 - Sign the server's CSR with your CA key

1. Create the configuration to be used for signing the CA cert.  Review the file openssl-ca-sign.cnf for more details.  Note the configuration has slightly different settings than the one originally used on step#1.

Again, make desired changes your have done in step#1 on ca_distinguished_name section.

2. Run the command sign-server-cert.sh, to sign the certificate.

After the command executes, you will have a freshly minted server certificate in servercert.pem. The private key was created earlier and is available in serverkey.pem.

3. Run the command print-signed-server-cert.sh to review the final certificate.

4. Run the command combine-server-certs.sh to combine the server certification and private key file into one file.

Step 4 - Install the server certificate on the server

Now, copy the files cacert.pem and serverall.pem to the desired server (non-production environments).

Say, if you want to copy on server with lighttpd, then go to /etc/lighttpd., create a folder ssl and copy these 2 files.  Now modify the /etc/lighttpd/lighttpd.conf file., ensure your map the path to cacert.pem & serverall.pem and restart the service.  Note, refer further documentation on web server to configure the settings.

Note, Lighttpd webserver needs both public and private keys in a single file hence we are combining it.  This many not be required on other servers.  In that case, use the file servercert.pem instead.

Step 5 - Install the CA certificate on the client

Depending on browser involved, you have to go to Browser settings page, Advance, Privacy settings.  Check for options to Manage certificates, then go to Authority tab, then click import and upload the cacert.pem file.
Now, this loads your custom CA Authority in the browser and will consider that signed server certificates.

You may have to do this setup on all the client browsers.

Note, if this your local development server, then you may have to map the server ip to the created spoof website name.  Go to /etc/hosts and create an entry like this...

192.168.1.23 my.co

Now when you type my.co in browser, it locates your non-prod webserver and then loads site with magical green lock sign.


Reference:
https://stackoverflow.com/questions/21297139/how-do-you-sign-a-certificate-signing-request-with-your-certification-authority/21340898#21340898
https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl
