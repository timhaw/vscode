resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins"
  role = aws_iam_role.jenkins.name
}