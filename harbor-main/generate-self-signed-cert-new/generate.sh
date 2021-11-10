rm *.crt *.key *.csr
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=myca" -days 10000 -out ca.crt
openssl genrsa -out domain.key 2048
openssl req -new -key domain.key -out domain.csr -config csr.conf
openssl x509 -req -in domain.csr -CA ca.crt -CAkey ca.key  -CAcreateserial -out domain.crt -days 10000  -extensions v3_ext -extfile csr.conf
openssl req  -noout -text -in ./domain.csr
openssl x509  -noout -text -in ./domain.crt
