kubectl minio tenant create \
      --name minio \
      --servers 1                             \
      --volumes 4                            \
      --capacity 100Gi                         \
      --namespace minio             \
      --storage-class local-storage
