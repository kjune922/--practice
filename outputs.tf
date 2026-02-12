output "final_ec2_ip" { 
  description = "접속할 ec2의 퍼블릭 주소"
  value = module.ec2.instance_public_ip
}

output "instnace_state" {
  description = "인스턴스 상태"
  value = module.ec2.instance_state
}

