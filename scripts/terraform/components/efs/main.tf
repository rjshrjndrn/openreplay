# Creating EFS file system
resource "aws_efs_file_system" "efs" {
creation_token = "my-efs"
tags = {
  Name = "MyProduct"
  }
}
# Creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_instance.web.subnet_id
  security_groups = [aws_security_group.ec2_security_group.id]
}
# Creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
  depends_on = [aws_efs_mount_target.mount]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.my_key.private_key_pem
    host     = aws_instance.web.public_ip
 }
