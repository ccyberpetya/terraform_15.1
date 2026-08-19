resource "yandex_iam_service_account" "storage_sa" {
  name = "storage-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "images" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key

  bucket = "cucuberpetya-netology-2026"

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_admin
  ]
}
resource "yandex_storage_object" "image" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key

  bucket       = yandex_storage_bucket.images.bucket
  key          = "image.jpg"
  source       = "${path.module}/image.jpg"
  content_type = "image/jpeg"
}