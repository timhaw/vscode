resource "aws_iam_policy" "jenkins" {
    name        = "jenkins"
    description = "A managed policy to allow the Jenkins EC2 instance to access AWS resources"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement01",
            "Effect": "Allow",
            "Action": [
                "autoscaling:*",
                "cloudformation:*",
                "cloudwatch:*",
                "ec2:*",
                "elasticbeanstalk:*",
                "elasticloadbalancing:*",
                "iam:*",
                "lambda:*",
                "logs:*",
                "route53:*",
                "s3:*",
                "secretsmanager:*",
                "sqs:*",
                "ssm:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "jenkins" {
    role       = aws_iam_role.jenkins.name
    policy_arn = aws_iam_policy.jenkins.arn
}
