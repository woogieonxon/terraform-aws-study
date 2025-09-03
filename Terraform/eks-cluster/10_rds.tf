# mysql  서브넷 그룹 생성
# resource "aws_db_subnet_group" "my_dbsg" {
#   name       = "my-dbsg"
#   subnet_ids = [aws_subnet.Private_db_subnet_a.id, aws_subnet.Private_db_subnet_c.id]
# }

# # DB 생성
# resource "aws_db_instance" "my_db" {
#   allocated_storage      = 20
#   storage_type           = "gp2"
#   engine                 = "mysql"
#   engine_version         = "8.0"
#   instance_class         = "db.t2.micro"
#   db_name                = "wordpress"
#   username               = "root"
#   password               = "It12345!"
#   multi_az               = true  # Multi-AZ 설정 활성화
#   identifier             = "mydb"
#   skip_final_snapshot    = true
#   vpc_security_group_ids = [aws_security_group.my_db_alb_sg.id]
#   availability_zone      = "ap-northeast-2a"
#   db_subnet_group_name   = aws_db_subnet_group.my_dbsg.id

#   tags = {
#     "Name" = "MySQL-DB"
#   }
# }


## aurora Subnet Group 생성
resource "aws_db_subnet_group" "aurora_dbsg" {
  name       = "aurora-dbsg"
  subnet_ids = [aws_subnet.Private_db_subnet_a.id, aws_subnet.Private_db_subnet_c.id]
  # 서브넷에 이미 소속 VPC, AZ 정보를 입력하여 생성하였기 때문에 , 서브넷 id만 나열해주면 subnet group 생성  
}

# RDS Cluster 생성
resource "aws_rds_cluster" "aurora_db" {
  cluster_identifier     = "database-1"                           # RDS Cluster 식별자명
  engine_mode            = "provisioned"                          # DB 인스턴스 생성 시 Provisioned (미설정시 default) 또는 Serverless 모드 지정
  db_subnet_group_name   = aws_db_subnet_group.aurora_dbsg.name   # DB가 배치될 서브넷 그룹 (.name으로 지정)
  vpc_security_group_ids = [aws_security_group.my_db_alb_sg.id]   # db 보안 그룹 지정
  engine                 = "aurora-mysql"                         # 엔진 유형
  engine_version         = "5.7.mysql_aurora.2.11.1"              # 엔진 버전
  availability_zones     = ["ap-northeast-2a", "ap-northeast-2c"] # 가용 영역
  database_name          = "auroradb"                             # 이름 명칭 구문 까다로움 (특수문자 들어가면 안됌)
  master_username        = "root"                                 # 인스턴스에서 직접 제어되는  DB Master User Name
  master_password        = "It12345!"
  skip_final_snapshot    = true # RDS 삭제시, 스냅샷 생성 X (True값으로 설정 시, terraform destroy 정상 수행 가능)
}

output "rds_writer_endpoint" {               # rds cluster의 writer 인스턴스 endpoint 추출 ( mysql 설정 및 Three-tier 연동파일에 정보 입력 필요해서 추출)
  value = aws_rds_cluster.aurora_db.endpoint # 해당 추출값은 terraform apply 완료 시 또는 terraform output rds_writer_endpoint로 확인 가능
}

# rds instance 생성
resource "aws_rds_cluster_instance" "aurora_db_instance" {
  count              = 2                            # RDS Cluster에 속한 총 2개의 DB 인스턴스 생성 ( Read /Writer로 지정)
  identifier         = "database-1-${count.index}"  # Instance의 식별자명 (count index로 0번부터 1씩 상승)
  cluster_identifier = aws_rds_cluster.aurora_db.id # 소속될 Cluster의 ID 지정
  instance_class     = "db.t3.small"                # DB 인스턴스 Class (메모리 최적화 / 버스터블 클래스 선택 없이 type 명만 적으면 됌)
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.11.1"
}

#failover 기능 추가
resource "null_resource" "failover_trigger" {
  provisioner "local-exec" {
    command = <<EOT
      sleep 120  # Writer 삭제 후 2분 동안 대기
      aws rds failover-db-cluster --db-cluster-identifier database-1 
#${aws_rds_cluster.aurora_db.cluster_identifier}
      sleep 300  # 프로모션 및 새로운 Read 인스턴스 생성을 위해 5분 동안 대기
      aws rds create-db-instance --db-cluster-identifier ${aws_rds_cluster.aurora_db.id} --db-instance-identifier aurora-instance-new --engine aurora --db-instance-class db.r5.large
    EOT
  }

  depends_on = [aws_rds_cluster.aurora_db]
}
