locals {
  exact_name  = "${var.state_bucket_name}-backup"
  description = "Versioned offsite copy of noisypigeon/garden's R2 Terraform state (LIB-0007)."
}
