    # assetsBucket: "tst-eks-openreplay-assets"
    # recordingsBucket: "tst-eks-openreplay-recordings"
    # sourcemapsBucket: "tst-eks-openreplay-sourcemaps"
variable "bucket_prefix" {
  description = "prefix of the bucket to create"
}
variable "bucket_acl" {
  description = "acl of the bucket to create"
}
