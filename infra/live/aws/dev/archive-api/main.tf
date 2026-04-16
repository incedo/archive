provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs                     = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))
  github_deploy_role_name = coalesce(var.github_deploy_role_name, "${var.project_name}-${var.environment}-github-actions-deploy")
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}"
  })
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "archive_api" {
  name        = "${var.project_name}-${var.environment}-${var.service_name}"
  description = "Security group for ${var.service_name}"
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = length(var.allowed_ingress_cidrs) == 0 ? [] : [1]
    content {
      description = "Direct access to archive-api"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.service_name}"
  })
}

resource "aws_secretsmanager_secret" "jdbc" {
  name = "${var.project_name}/${var.environment}/${var.service_name}/jdbc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.service_name}-jdbc"
  })
}

resource "aws_secretsmanager_secret_version" "jdbc" {
  secret_id = aws_secretsmanager_secret.jdbc.id
  secret_string = jsonencode({
    ARCHIVE_JDBC_URL      = var.jdbc_url
    ARCHIVE_JDBC_USER     = var.jdbc_user
    ARCHIVE_JDBC_PASSWORD = var.jdbc_password
  })
}

module "archive_api_service" {
  source = "../../../../modules/aws/archive_api_service"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  service_name          = var.service_name
  container_name        = var.container_name
  image_uri             = var.image_uri
  subnet_ids            = aws_subnet.public[*].id
  security_group_ids    = [aws_security_group.archive_api.id]
  jdbc_secret_arn       = aws_secretsmanager_secret.jdbc.arn
  assign_public_ip      = var.assign_public_ip
  desired_count         = var.desired_count
  cpu                   = var.cpu
  memory                = var.memory
  log_retention_in_days = var.log_retention_in_days
  target_group_arn      = var.target_group_arn
  tags                  = var.tags
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_provider_thumbprints

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-github-actions"
  })
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:${var.github_environment_name}"]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name               = local.github_deploy_role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = merge(var.tags, {
    Name = local.github_deploy_role_name
  })
}

data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    sid    = "AllowEcrAuthentication"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowEcrPush"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [module.archive_api_service.ecr_repository_arn]
  }

  statement {
    sid    = "AllowEcsReadWrite"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPassRuntimeRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      module.archive_api_service.execution_role_arn,
      module.archive_api_service.task_role_arn,
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name   = "${local.github_deploy_role_name}-policy"
  role   = aws_iam_role.github_actions_deploy.id
  policy = data.aws_iam_policy_document.github_actions_deploy.json
}
