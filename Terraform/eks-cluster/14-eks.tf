resource "aws_iam_role" "eks_roles" {
  name = "eks_cluster_roles"


  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_roles_AmazoneEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_roles.name
}
resource "aws_iam_role_policy_attachment" "eks_roles_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_roles.name
}
resource "aws_eks_cluster" "eks-clusters" {
  name     = "eks-clusters"
  role_arn = aws_iam_role.eks_roles.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.Private_was_subnet_a.id,
      aws_subnet.Private_was_subnet_c.id,
    ]
  }

  # depends_on = [aws_iam_role_policy_attachment.eks_roles_AmazonEKSClusterPolicy]
}

