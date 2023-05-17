terraform {
  backend "remote" {
    organization = "sac-org"
    workspaces {
      name = "tf-cloud-workspace"
    }
  }
}
