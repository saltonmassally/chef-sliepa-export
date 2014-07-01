default[:openerp][:apt_packages] = %w[
  libssl-dev
  libsasl2-dev
  libldap2-dev
  libxml2-dev 
  libxslt1-dev
  libjpeg-dev
  libjpeg8-dev
  graphviz
  libevent-dev
  ghostscript
  poppler-utils
]

default[:openerp][:pip_packages] = %w[
  raven
  raven-sanitize-openerp
  wkhtmltopdf
]
  
default[:openerp][:database][:name] = 'openerp'
default[:openerp][:database][:host] = 'localhost'
default[:openerp][:database][:port] = 5432
default[:openerp][:database][:password] = 'secret'
default[:openerp][:database][:user] = 'openerp'
default[:openerp][:database][:maxconn] = 300
default[:openerp][:servername] = 'export.sliepa.sl'


default[:openerp][:data_dir] = '/mnt/data/openerp'
default[:openerp][:db_filter] = '^%d$'
default[:openerp][:debug_mode] = 'False'
default[:openerp][:email_from] = 'info@sliepa.sl'

default[:openerp][:admin_pass] = 'supersecret'
default[:openerp][:addon_path] = 'openerp/addons/'
default[:openerp][:sentry_dsn] = 'secret'
default[:openerp][:aws_access_key] = 'secret'
default[:openerp][:aws_secret_key] = 'secret'
default[:openerp][:route53_zone_id] = ''
default[:openerp][:domain] = ''
default[:openerp][:workers] = 3
default[:openerp][:elastic_ip] = ''
default[:openerp][:static_http_document_root] = '/var/www/'
default[:openerp][:static_http_url_prefix]= '/static'


default[:openerp][:update_command] = ''

override['supervisor']['inet_port'] = '9001'

override['nginx']['worker_processes'] = 4
override['nginx']['default_site_enabled'] = false
override['nginx']['gzip'] = 'on'

override['postgresql']['enable_pgdg_apt'] = true 
override['postgresql']['version'] = '9.3'
override['postgresql']['data_directory'] = '/mnt/data/postgresql/#{node["postgresql"]["version"]}/main'
override[:chef_ec2_ebs_snapshot][:description] = "export.sliepa.sl data directory Backup $(date +'%Y-%m-%d %H:%M:%S')" 

#set the ff in stack settings
# node['supervisor']['inet_username']
# node['supervisor']['inet_password']
#
#
#
#
#
#
#


