velero install \
--provider aws \
--bucket velero \
--secret-file ./credentials-velero \
--plugins velero/velero-plugin-for-aws:v1.3.0 \
--snapshot-location-config region=minio \
--backup-location-config \
region=minio,s3ForcePathStyle="true",s3Url=http://10.213.227.70:9000,publicUrl=http://10.213.227.70:9000 \
--use-restic \
--default-volumes-to-restic 
