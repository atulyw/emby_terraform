locals {
  userdata = <<EOT
#!/bin/bash
sudo apt-get update
sudo apt-get install automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config unzip zip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo apt install s3fs -y
which s3fs
sudo touch /etc/passwd-s3fs
echo "${var.s3_access_key}:${var.s3_secret_key}" | sudo tee -a /home/ubuntu/.s3fs-creds
chmod 600 /home/ubuntu/.s3fs-creds
mkdir /emby_bucket
#s3fs ${var.bucket_name} -o use_cache=/tmp -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 /emby_bucket  
sudo s3fs ${var.bucket_name} /emby_bucket -o passwd_file=/home/ubuntu/.s3fs-creds
sudo mount -av
wget https://github.com/MediaBrowser/Emby.Releases/releases/download/4.6.7.0/emby-server-deb_4.6.7.0_amd64.deb
sudo dpkg -i emby-server-deb_4.6.7.0_amd64.deb
sudo service emby-server start
EOT
}