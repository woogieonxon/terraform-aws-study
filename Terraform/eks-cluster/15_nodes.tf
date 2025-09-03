resource "aws_iam_role" "nodes" {
  name = "eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# EKS Worker Node Policy

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# EKS CNI Policy

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Allow to download and run Docker images from the ECR repository

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# EKS Cluster Autoscaler Policy

resource "aws_iam_role_policy_attachment" "nodes-eks-cluster-autoscaler" {
  policy_arn = "arn:aws:iam::xxxxxxxxxxxx:policy/eks-cluster-autoscaler"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "eks-web-nodes" {
  cluster_name    = aws_eks_cluster.eks-clusters.name
  node_group_name = "eks-web-nodes"
  node_role_arn   = aws_iam_role.nodes.arn


  subnet_ids = [
    aws_subnet.Private_was_subnet_a.id,
    aws_subnet.Private_was_subnet_c.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 4
    max_size     = 8
    min_size     = 4
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

# taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }


  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.nodes-eks-cluster-autoscaler,
  ]
}

#resource "aws_autoscaling_policy" "eks-app-nodes-scaling-policy" {
#  name                   = "eks-app-nodes-scaling-policy"
#  scaling_adjustment    = 1
#  cooldown               = 300 # Optional: Set your cooldown period
#  adjustment_type       = "ChangeInCapacity"
# min_adjustment_step   = 1

# Instead of using scaling_target block, specify autoscaling_group_name directly
#  autoscaling_group_name = aws_eks_node_group.eks-app-nodes.name
#}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }