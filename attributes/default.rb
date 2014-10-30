#
# Cookbook Name:: chef-haproxy-ng
# Attributes:: chef-haproxy-ng
#
default['haproxy']['package'] = "haproxy"
default['haproxy']['user'] = "haproxy"
default['haproxy']['group'] = "haproxy"
default['haproxy']['conf_dir'] = '/etc/haproxy'

default['haproxy']['global_options'] = {}
default['haproxy']['global_max_connections'] = 4096

default['haproxy']['mode'] = "http"
default['haproxy']['balance_algorithm'] = "roundrobin"
default['haproxy']['defaults_timeouts']['connect'] = "5s"
default['haproxy']['defaults_timeouts']['client'] = "50s"
default['haproxy']['defaults_timeouts']['server'] = "50s"
default['haproxy']['defaults_options'] = ["httplog", "dontlognull", "redispatch"]

default['haproxy']['admin']['enable'] = true
default['haproxy']['admin']['bind'] = "127.0.0.1:22002"
default['haproxy']['admin']['options'] = [ 'stats uri /', 'stats refresh 5s' ]

default['haproxy']['member_max_connections'] = 100
default['haproxy']['frontend_max_connections'] = 2000
default['haproxy']['frontend_ssl_max_connections'] = 2000

default['haproxy']['pool_members'] = {}
default['haproxy']['listeners'] = {
  'listen' => {},
  'frontend' => {},
  'backend' => {}
}

