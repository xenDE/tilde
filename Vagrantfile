# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "precise32"

  # APT proxy configuration
  if ENV['FTP_PROXY']
    config.vm.provision :shell,
      :inline => "echo 'Acquire::ftp::proxy \"#{ENV['FTP_PROXY']}\";' >> /etc/apt/apt.conf.d/01proxy"
  end
  if ENV['HTTP_PROXY']
    config.vm.provision :shell,
      :inline => "echo 'Acquire::http::proxy \"#{ENV['HTTP_PROXY']}\";' >> /etc/apt/apt.conf.d/01proxy"
  end
  if ENV['HTTPS_PROXY']
    config.vm.provision :shell,
      :inline => "echo 'Acquire::https::proxy \"#{ENV['HTTPS_PROXY']}\";' >> /etc/apt/apt.conf.d/01proxy"
  end
  if ENV['SOCKS_PROXY']
    config.vm.provision :shell,
      :inline => "echo 'Acquire::socks::proxy \"#{ENV['SOCKS_PROXY']}\";' >> /etc/apt/apt.conf.d/01proxy"
  end
end