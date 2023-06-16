data "ansiblevault_path" "github-token" {
  path = "${path.module}/secrets.yml"
  key  = "github-token"
}

data "ansiblevault_path" "github-user" {
  path = "${path.module}/secrets.yml"
  key  = "github-user"
}

data "ansiblevault_path" "jenkins_agent_1_secret" {
  path = "${path.module}/secrets.yml"
  key  = "jenkins_agent_1_secret"
}

data "ansiblevault_path" "jenkins_agent_2_secret" {
  path = "${path.module}/secrets.yml"
  key  = "jenkins_agent_2_secret"
}

data "ansiblevault_path" "jenkins_archive_password" {
  path = "${path.module}/secrets.yml"
  key  = "jenkins_archive_password"
}