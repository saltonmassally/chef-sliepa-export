#
# Cookbook Name:: openerp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'idt_infra_tools'
include_recipe "python"
include_recipe "supervisor"
include_recipe "nginx::repo"
include_recipe "nginx"
include_recipe "nginx::http_stub_status_module"
include_recipe 'postgresql::client'

# lets set the python egg cache
directory "/tmp/python-eggs" do
  owner "root"
  group "root"
  mode 00777
  action :create
end

magic_shell_environment 'PYTHON_EGG_CACHE' do
  value '/tmp/python-eggs'
end

magic_shell_environment 'PYTHONPATH' do
  value '/usr/local/lib/python2.7/dist-packages:/usr/local/lib/python2.7/site-packages'
end


node[:openerp][:apt_packages].each do |pkg|
  package pkg do
    action :install
  end
end

# lets ensure that pillow has jpeg support
bash "correct_for_pillow" do
  code <<-EOH
    ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
    ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
    ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
  EOH
end


cookbook_file "404.tar.gz" do
  path "#{node[:openerp][:static_http_document_root]}404.tar.gz"
  user node[:openerp][:user]
  group node[:openerp][:group]
end

# lets ensure that pillow has jpeg support
bash "setup_404" do
  code <<-EOH
  tar xzf 404.tar.gz
  EOH
  cwd node[:openerp][:static_http_document_root]
end
