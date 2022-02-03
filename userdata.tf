locals {
  userdata = <<EOT
#!/bin/bash
sudo apt-get update
sudo apt-get install automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config unzip zip acl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo apt install s3fs -y
which s3fs
sudo touch /.s3fs-creds
echo "${var.s3_access_key}:${var.s3_secret_key}" | sudo tee -a /.s3fs-creds
sudo chmod 600 /.s3fs-creds
sudo mkdir /mnt/emby_bucket
sudo chmod -R 777 /mnt/emby_bucket
#sudo s3fs ${var.bucket_name}:/ /mnt/emby_bucket -o passwd_file=/.s3fs-creds,nonempty
echo "s3fs#${var.bucket_name} /mnt/emby_bucket fuse _netdev,allow_other,passwd_file=/.s3fs-creds 0 0" | sudo tee -a /etc/fstab
sudo mount -av
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/4.6.7.0/emby-server-deb_4.6.7.0_amd64.deb
sudo dpkg -i emby-server-deb_4.6.7.0_amd64.deb
sudo chmod -R 777 /mnt/emby_bucket
sudo service emby-server start
EOT
}