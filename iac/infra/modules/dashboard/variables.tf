variable "location" {}
variable "resource_group_name" {}
variable "databricks_id" {}
variable "storage_id" {}
variable "eventhub_id" {}
variable "postgres_id" {}

variable "function_names" {
  type    = list(string)
  default = [
    "news_producer",
    "ri_resumer",
    "ri_collector",
    "finance_csv_ingestor",
    "postgres_ingestor",
    "news_sentiment_analyzer"
  ]
}


