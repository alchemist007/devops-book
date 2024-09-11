provider "aws" {
  region = "us-east-2"
}

module "s3_bucket" {
  source = "github.com/brikis98/devops-book//ch9/tofu/modules/s3-website"

  # TODO: fill in your own bucket name!
  name           = "fundamentals-of-devops-static-website" 
  index_document = "index.html"                            
}

locals {
  files_to_upload = {                            
    "index.html" = "text/html"
    "styles.css" = "text/css"
    "cover.png"  = "image/png"
  }
}

resource "aws_s3_object" "content" {
  for_each      = local.files_to_upload          
  bucket        = module.s3_bucket.bucket_name   
  key           = each.key                       
  source        = "content/${each.key}"          
  etag          = filemd5("content/${each.key}") 
  content_type  = each.value                     
  cache_control = "public, max-age=300"          
}

module "cloudfront" {
  source = "github.com/brikis98/devops-book//ch9/tofu/modules/cloudfront-s3-website"

  bucket_name             = module.s3_bucket.bucket_name      
  bucket_website_endpoint = module.s3_bucket.website_endpoint 

  min_ttl     = 0                                             
  max_ttl     = 300
  default_ttl = 0

  default_root_object = "index.html"                          
}
