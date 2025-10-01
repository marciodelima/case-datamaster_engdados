variable "location" {}
variable "resource_group_name" {}
variable "databricks_id" {}
variable "storage_id" {}
variable "eventhub_id" {}
variable "postgres_id" {}

variable "function_names" {
  type = list(string)
  default = [
    "news-producer-func",
    "ri-resumer-func",
    "ri-collector-func",
    "finance-csv-ingestor-func",
    "postgres-ingestor-func",
    "news-sentiment-analyzer-func"
  ]
}


