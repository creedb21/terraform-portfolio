provider "aws" {
  region = "ap-south-1"
}


//Creating an S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.buck_name
}

//Setting up bucket ownership
resource "aws_s3_bucket_ownership_controls" "mybucket" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

//Making the bucket public
resource "aws_s3_bucket_public_access_block" "mybucket" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

//Modiying ACL Access policy
resource "aws_s3_bucket_acl" "mybucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mybucket,
    aws_s3_bucket_public_access_block.mybucket,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

//Adding the index.html file as an object to the bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key =  "index.html"
  source = "./webpage/index.html"
  acl = "public-read"
  content_type = "text/html"
}

//Adding the error.html file as an object to the bucket
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key =  "error.html"
  source = "./webpage/error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "profile" {
  bucket = aws_s3_bucket.mybucket.id
  key = "profile.jpg"
  source = "./webpage/profile.jpg"
  acl = "public-read"
}

//Configuring the website
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
  //This should create after below
  depends_on = [ aws_s3_bucket_acl.mybucket ]
}