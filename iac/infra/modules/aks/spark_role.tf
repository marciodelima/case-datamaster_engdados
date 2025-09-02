resource "kubernetes_role" "spark_role" {
  metadata {
    name      = "spark-role"
    namespace = "spark"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "persistentvolumeclaims"]
    verbs      = ["create", "get", "list", "watch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["create", "get", "list", "watch", "delete"]
  }
  depends_on = [kubernetes_namespace.services]
}

resource "kubernetes_role_binding" "spark_binding" {
  metadata {
    name      = "spark-binding"
    namespace = "spark"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.spark_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "spark-sa"
    namespace = "spark"
  }
  depends_on = [kubernetes_namespace.services]
}

resource "kubernetes_role" "airflow_spark_apply" {
  metadata {
    name      = "airflow-spark-apply"
    namespace = "airflow"
  }

  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources  = ["sparkapplications"]
    verbs      = ["create", "get", "list", "watch", "delete", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
  depends_on = [kubernetes_namespace.services]
}

resource "kubernetes_role_binding" "airflow_spark_binding" {
  metadata {
    name      = "airflow-spark-binding"
    namespace = "airflow"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.airflow_spark_apply.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "airflow-sa"
    namespace = "airflow"
  }
  depends_on = [kubernetes_namespace.services]
}

