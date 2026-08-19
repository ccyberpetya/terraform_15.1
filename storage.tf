# Сервисный аккаунт для Object Storage
resource "yandex_iam_service_account" "storage_sa" {
  name = "storage-sa"
}

# Права сервисного аккаунта на Object Storage
resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Статический ключ сервисного аккаунта
resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  description        = "static access key for object storage"
}

# Object Storage bucket
resource "yandex_storage_bucket" "images" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key

  bucket = "cucuberpetya-netology-2026"

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }

  # Шифрование объектов бакета с помощью KMS
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.storage_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_admin,
    yandex_kms_symmetric_key_iam_member.storage_kms_access
  ]
}

# Картинка в Object Storage
resource "yandex_storage_object" "image" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key

  bucket       = yandex_storage_bucket.images.bucket
  key          = "image.jpg"
  source       = "${path.module}/image.jpg"
  source_hash  = filemd5("${path.module}/image.jpg")
  content_type = "image/jpeg"

  depends_on = [
    yandex_storage_bucket.images
  ]
}