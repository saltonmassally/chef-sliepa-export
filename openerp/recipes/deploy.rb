#
# Cookbook Name:: openerp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "supervisor"
include_recipe "openerp"
include_recipe "nginx::repo"
include_recipe "nginx"
include_recipe "nginx::http_stub_status_module"

include_recipe 'deploy'

node[:deploy].each do |application, deploy|
   if deploy[:application_type] != 'other'
     Chef::Log.debug("Skipping deploy::other application #{application} as it is not an other app")
     next
   end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  # create data dir if for some reason its not there
  directory node[:openerp][:data_dir] do
    owner deploy[:user]
    group deploy[:group]
    mode 00755
    action :create
    not_if { ::File.exists?(node[:openerp][:data_dir]) }
  end

# lets ensure that the data dir is writable
  bash "correct_directory_permission" do
    command "chown {deploy[:user]}:{deploy[:group]} {node[:openerp][:data_dir]}; chmod 775 {node[:openerp][:data_dir]}"
    only_if { ::File.exists?(node[:openerp][:data_dir]) }
  end

  node[:openerp][:pip_packages].each do |pkg|
    python_pip pkg do
      action :install
    end
  end

  script 'execute_setup' do
    interpreter "bash"
    user "root"
    cwd deploy[:absolute_document_root]
    code "python setup.py install"
  end

  script 'chmod_gevent' do
    interpreter "bash"
    user "root"
    cwd deploy[:absolute_document_root]
    code "chmod +x openerp-gevent"
  end

# lets bring back sanity
  bash "fix_packages" do
    cwd '/tmp'
    code <<-EOH
    wget http://python-distribute.org/distribute_setup.py
    python distribute_setup.py
    EOH
  end

  template "#{deploy[:absolute_document_root]}openerp-wsgi.py" do
    source "openerp-wsgi.py.erb"
    owner deploy[:user]
    group deploy[:group]
    mode "0644"
    action :create
    variables(
      :deploy_path => deploy[:absolute_document_root],
      :log_file =>  "#{deploy[:deploy_to]}/shared/log/openerp.log",
      :pid_file =>  "#{deploy[:deploy_to]}/shared/pids/openerp.pid",
      :database => deploy[:database]
    )    
  end

  template "#{deploy[:absolute_document_root]}openerp/conf/openerp.conf" do
    source "openerp.conf.erb"
    owner deploy[:user]
    group deploy[:group]
    mode "0644"
    action :create
    variables(
      :deploy_path => deploy[:absolute_document_root],
      :log_file =>  "#{deploy[:deploy_to]}/shared/log/openerp.log",
      :pid_file =>  "#{deploy[:deploy_to]}/shared/pids/openerp.pid",
      :database => deploy[:database]
    ) 
  end

  template "/home/#{deploy[:user]}/.openerp_serverrc" do
    source "openerp.conf.erb"
    owner deploy[:user]
    group deploy[:group]
    mode "0644"
    action :create
    variables(
      :deploy_path => deploy[:absolute_document_root],
      :log_file =>  "#{deploy[:deploy_to]}/shared/log/openerp.log",
      :pid_file =>  "#{deploy[:deploy_to]}/shared/pids/openerp.pid",
      :database => deploy[:database]
    ) 
  end

  supervisor_service "openerp" do
    command "python ./openerp-server"
    directory deploy[:absolute_document_root]
    user deploy[:user]
    autostart true
    autorestart true
    environment :HOME => "/home/#{deploy[:user]}",:PYTHON_EGG_CACHE => "/tmp/python-eggs",:UNO_PATH => "/usr/lib/libreoffice/program/",:PYTHONPATH => "/usr/local/lib/python2.7/dist-packages:/usr/local/lib/python2.7/site-packages"
  end

  supervisor_service "openerp" do
    action :stop
  end

  service "postgresql" do
    action :restart
  end


  script 'execute_db_update' do
    interpreter "bash"
    user deploy[:user]
    cwd deploy[:absolute_document_root]
    environment 'HOME' => "/home/#{deploy[:user]}"
    code "python db_update.py --backup_dir=#{node[:openerp][:data_dir]}/backups/"
    notifies :restart, "supervisor_service[openerp]"
  end

  template "/etc/nginx/sites-enabled/ngnix-openerp" do
    source "ngnix-openerp.conf.erb"
    variables({
      :deploy_path => deploy[:absolute_document_root],
    })
    notifies :reload, 'service[nginx]'
  end

  nginx_site "ngnix-openerp" do
    enable true
  end
 

end


