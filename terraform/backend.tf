terraform {
  backend "remote" {
    organization = "sac-org"
    workspaces {
      name = "openapi-petstore"
    }
  }
}
