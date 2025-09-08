provider "aws" {
  region = "us-east-1"
  alias = "us"
}

provider "aws" {
  region = "ap-south-1"
  alias = "mumbai"
}

resource "aws_instance" "usec2" {
  provider = aws.us
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  tags = {
    Name = "EC2US"
  }
}

resource "aws_instance" "mumbaiec2" {
  provider = aws.mumbai
  ami = "ami-02d26659fd82cf299"
  instance_type = "t2.micro"
  tags = {
    Name = "EC2MUMBAI"
  }
}

resource "random_id" "random_value" {
  byte_length = 4
}

resource "aws_s3_bucket" "usbucket" {
  provider = aws.us
  bucket = "us${random_id.random_value.hex}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.usbucket.id
  provider = aws.us

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket" "mumbaibucket" {
  provider = aws.mumbai
  bucket = "mumbai${random_id.random_value.hex}"
}

resource "aws_s3_bucket_public_access_block" "example1" {
  bucket = aws_s3_bucket.mumbaibucket.id
  provider = aws.mumbai
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "example_policy" {
  bucket = aws_s3_bucket.mumbaibucket.id
  provider = aws.mumbai

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.mumbaibucket.id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "example_policy1" {
  bucket = aws_s3_bucket.usbucket.id
  provider = aws.us
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.usbucket.id}/*"
      }
    ]
  })
}