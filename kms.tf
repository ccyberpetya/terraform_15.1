resource "yandex_kms_symmetric_key" "storage_key" {
  name              = "storage-kms-key"
  description       = "KMS key for Object Storage encryption"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}
resource "yandex_kms_symmetric_key_iam_member" "storage_kms_access" {
  symmetric_key_id = yandex_kms_symmetric_key.storage_key.id
  role             = "kms.keys.encrypterDecrypter"
  member           = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}