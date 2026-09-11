
## https://medium.com/@sureshchand.rhce/how-to-build-a-root-ca-intermediate-ca-with-openssl-eba1c73d1591

set -x -e
# output folder should be match with dir from *.conf
export OUTPUT=./certs && rm -rf $OUTPUT && mkdir -p $OUTPUT

# root key
#openssl genpkey -algorithm RSA -out root_ca_key.pem  -pkeyopt rsa_keygen_bits:4096 
openssl genrsa -out $OUTPUT/root_ca_key.pem 4096 
chmod 400 $OUTPUT/root_ca_key.pem

# root CA
openssl req -x509 -new -nodes -config root_ca.conf -days 3650  -key $OUTPUT/root_ca_key.pem -sha256 -extensions v3_ca -out $OUTPUT/root_ca_cert.pem
chmod 444 $OUTPUT/root_ca_cert.pem

# Create the Intermediate CA
openssl genpkey -algorithm RSA -out $OUTPUT/intermediate.key.pem  -pkeyopt rsa_keygen_bits:4096 
openssl req -config inter_ca.conf -new -key $OUTPUT/intermediate.key.pem -out $OUTPUT/intermediate.csr.pem

# Sign the Intermediate with the Root CA
touch $OUTPUT/root_index.txt
touch $OUTPUT/intermediate_index.txt
echo 1000 > $OUTPUT/root_ca_serial
echo 1000 > $OUTPUT/intermediate_serial
openssl ca -config root_ca.conf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in $OUTPUT/intermediate.csr.pem -out $OUTPUT/intermediate.cert.pem -batch
chmod 444 $OUTPUT/intermediate.cert.pem

# Build a chain file
openssl verify -CAfile $OUTPUT/root_ca_cert.pem $OUTPUT/intermediate.cert.pem
cat $OUTPUT/intermediate.cert.pem $OUTPUT/root_ca_cert.pem > $OUTPUT/ca_chain.cert.pem

#  Issue a Server Certificate
openssl genpkey -algorithm RSA -out $OUTPUT/server.key.pem -pkeyopt rsa_keygen_bits:2048
openssl req -new -key $OUTPUT/server.key.pem -out $OUTPUT/server.csr.pem -config server.conf

# Sign with Intermediate CA
openssl ca -config inter_ca.conf -days 825 -notext -md sha256 -in $OUTPUT/server.csr.pem -out $OUTPUT/server.cert.pem  -extensions v3_ext -extfile server.conf -batch

# Verify server cert using CA chain
openssl verify -CAfile $OUTPUT/ca_chain.cert.pem $OUTPUT/server.cert.pem

echo "\n"
openssl x509 -text -noout -in $OUTPUT/root_ca_cert.pem
echo "\n"
openssl x509 -text -noout -in $OUTPUT/intermediate.cert.pem
echo "\n"
openssl x509 -text -noout -in $OUTPUT/server.cert.pem


# clean up
rm -rf $OUTPUT/*_index.txt*
rm -rf $OUTPUT/*_serial* 
rm -rf $OUTPUT/1000.pem

