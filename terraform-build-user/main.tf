module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws                       = aws
    aws.images-production-ami = aws.images-production-ami
    aws.images-staging-ami    = aws.images-staging-ami
    aws.images-production-ssm = aws.images-production-ssm
    aws.images-staging-ssm    = aws.images-staging-ssm
  }

  ssm_parameters = [
    "/cyhy/dev/users",
    "/ssh/public_keys/*",
    "/vnc/username",
    "/vnc/password",
    "/vnc/ssh/rsa_public_key",
    "/vnc/ssh/rsa_private_key",
  ]
  user_name = "test-teamserver-packer"
  tags = {
    Team        = "CISA - Development"
    Application = "teamserver-packer"
  }
}

# Attach 3rd party S3 bucket read-only policy from
# cisagov/ansible-role-cobalt-strike to the production EC2AMICreate
# role
resource "aws_iam_role_policy_attachment" "thirdpartybucketread_production" {
  provider = aws.images-production-ami

  policy_arn = data.terraform_remote_state.ansible_role_cobalt_strike.outputs.production_policy.arn
  role       = module.iam_user.ec2amicreate_role_production.name
}

# Attach 3rd party S3 bucket read-only policy from
# cisagov/ansible-role-cobalt-strike to the staging EC2AMICreate role
resource "aws_iam_role_policy_attachment" "thirdpartybucketread_staging" {
  provider = aws.images-staging-ami

  policy_arn = data.terraform_remote_state.ansible_role_cobalt_strike.outputs.staging_policy.arn
  role       = module.iam_user.ec2amicreate_role_staging.name
}
