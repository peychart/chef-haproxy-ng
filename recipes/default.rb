#
# Cookbook Name:: chef-haproxy-ng
# Recipe:: default
#
# Copyright (C) 2014 PE, pf.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# PE-20140916

package 'haproxy' do
 package_name node['haproxy']['package']
#options('--force')
 action :upgrade
end

# Config file:
if node["haproxy"] && node["haproxy"].any?
  haproxy =  node.default["haproxy"]

#include_recipe "haproxy::install_#{node['haproxy']['install_method']}"

  # init files:
  cookbook_file '/etc/default/haproxy' do
    source 'haproxy-default'
    owner 'root'
    group 'root'
    mode 00644
    action :create
  end

  i=1; while i do
    i = haproxy['conf_dir'].sub(/\/$/, '').index('/', i)
    if i
         filename = haproxy['conf_dir'][0..i]; i += 1
    else filename = haproxy['conf_dir']
    end
    directory filename do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

  template '/etc/init.d/haproxy' do
    source 'haproxy-init.erb'
    mode 0755
    owner 'root'
    group 'root'
    variables(
     :conf_dir  => haproxy['conf_dir']
    )
  end

  listeners=[]

  # Admin definition:
  if haproxy['admin']['enable']
    options = []
    options << "bind #{haproxy['admin']['bind']}"
    options << 'mode http'
    haproxy['admin']['options'].each do |i|
      options << i
    end
    listeners << { 'listen' => { 'admin' => options.uniq } }
  end

  # For each service:
  haproxy['listeners'].each do |name, listener|
    if listener.any?

      # getenv(others nodes['app_server_role'] definitions):
############## SUBSTITUTE WITH A OHAI SEARCH... #################
      data_bag('clusters').each do |item|
        if item != node['fqdn'].gsub(".", "_")
          i = data_bag_item('clusters', item)['haproxy']
          i = i['listeners'] if i
          $getEnv.call( haproxy['listeners'][name], i[name] ) if i && i[name]
        end
      end

      # Defaults definition:
      if listener['defaults'].any?
        listeners << { 'defaults' => { '' => listener['defaults'] } }
      end if listener['defaults']

      # Listen definition:
      options = []
      if listener['bind'].is_a? Array
        listener['bind'].each do |i|
           options << "bind #{i}"
        end
      else options << "bind #{listener['bind']}"
      end if listener['bind'] && listener['bind']!={}

      listener.each do |name, i|
        if name != 'defaults' && name != 'bind' && name != 'pool_members'
          options << "#{name} #{i}"
        end
      end

      listener['pool_members'].each do |i|
        options << "server #{i}"
      end if listener['pool_members']

      listeners << { 'listen' => { name => options } } if options.any?

    end
  end

  template "#{haproxy['conf_dir']}/haproxy.cfg" do
    source 'haproxy.cfg.erb'
    mode 00644
    owner 'root'
    group 'root'
    variables(
     :listeners => listeners
    )
  end if listeners.any?

end
