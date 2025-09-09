provider "aws" {
    region = "us-east-1"
    alias = "us"
}

provider "aws" {
    region = "ap-south-1"
    alias = "ap"
}

resource "random_id" "random_name" {
    byte_length = 4
}

resource "aws_s3_bucket" "usbucket" {
    provider = aws.us
  bucket = "usbucket${random_id.random_name.hex}"
}

resource "aws_s3_bucket" "mumbaibucket" {
  provider = aws.ap
  bucket = "mumbaibucket${random_id.random_name.hex}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.usbucket.id
  provider = aws.us
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_public_access_block" "example1" {
  bucket = aws_s3_bucket.mumbaibucket.id
  provider = aws.ap
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "public_read" {
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
        Resource = "${aws_s3_bucket.usbucket.arn}/*"
      }
    ]
  })
}



resource "aws_s3_bucket_policy" "public_read1" {
  bucket = aws_s3_bucket.mumbaibucket.id
  provider = aws.ap
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.mumbaibucket.arn}/*"
      }
    ]
  })
}


resource "aws_s3_object" "myfile" {
    provider = aws.us
bucket = aws_s3_bucket.usbucket.id
  key    = "hello.txt"                       # File name in S3
  source = "myfile.txt"  
}
