# Cloud-AI-Infra: AWS & IaC Automation Project
"Terraform과 Docker를 활용한 고가용성 AWS 3-Tier 인프라 및 CI/CD 파이프라인 구축"

1. 프로젝트 개요
목적: 수동 인프라 구축의 한계를 극복하기 위해 **IaC(Terraform)**를 도입하고, 애플리케이션의 컨테이너화(Docker) 및 자동 배포(GitHub Actions) 환경을 구현함.

핵심 성과: 1분 20초 이내에 전체 인프라 리소스 배포 및 애플리케이션 업데이트 완료.

2. 시스템 아키텍처
![Architecture Diagram](https://drive.google.com/drive/folders/16ZqB2ZX1B06X5lUVnuWdliIuK-JQOD5Q?hl=ko)

3. 주요 구현 특징
Infrastructure as Code (IaC): Terraform을 사용하여 VPC, Subnet, ALB, EC2, RDS, S3(Remote Backend)를 코드로 관리.

고가용성(High Availability): Multi-AZ 설계를 통해 가용 영역 장애에 대비한 안정적인 서비스 환경 구축.

보안 및 망 분리: Public/Private 서브넷을 엄격히 분리하여 데이터베이스(RDS)를 외부 위협으로부터 보호.

CI/CD 파이프라인: GitHub Actions를 통해 Docker 이미지를 빌드하고 AWS ECR에 자동 푸시하는 배포 자동화 구현.

4. 사용 기술 (Tech Stack)
Cloud: AWS (VPC, EC2, ALB, RDS, S3, ECR)

Automation/IaC: Terraform, GitHub Actions

Container: Docker, FastAPI (Python)
