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
  haproxy = node.default["haproxy"]

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

  # For each listener:
  listeners=[]
  haproxy['listener'].each do |listenerName, listenerDef|
    if listenerDef.any?

      # Defaults definition:
      if listenerDef['defaults'].any?
        listeners << { 'defaults' => { '' => listenerDef['defaults'] } }
      end if defined? listenerDef['defaults']

      # Listener definition:
      options = []
      if listenerDef['bind'].is_a? Array
        listenerDef['bind'].each do |i|
           options << "bind #{i}"
        end
      else options << "bind #{listenerDef['bind']}"
      end if defined? listenerDef['bind']

      listenerDef.each do |name, i|
        if name != 'defaults' && name != 'bind' && name != 'pool_member'
 
          ( (i.is_a? Array) ? i : Array[i] ).each do |j|
            options << ( name[name.length-1] != '-' ? "#{name} #{j}" : j )
          end

        end
      end

      poolMembersDef = listenerDef['pool_member']
      if poolMembersDef && poolMembersDef != {}
        options << "server #{node['fqdn']} #{node['fqdn']}:#{poolMembersDef['bind']} #{poolMembersDef['option']}"

        # For each server in the Chef database:
        search("node", "domain:#{node['domain']} AND haproxy:* AND haproxy_listener:*").each do |server|
          if server['haproxy']['listener'][listenerName] && server['haproxy']['listener'][listenerName] != {} && server['haproxy']['listener'][listenerName]['pool_member'] != {}
            backup = (server['haproxy']['listener'][listenerName]['pool_member']['othersAreBackup'] ? ' backup' : '')
            options << "server #{server['fqdn']} #{server['fqdn']}:#{server['haproxy']['listener'][listenerName]['pool_member']['bind']} #{server['haproxy']['listener'][listenerName]['pool_member']['option']}#{backup}"
          end
        end

        poolMembersDef[node['domain']].each do |i|
          options << i
        end if poolMembersDef[node['domain']]
      end

      listeners << { 'listen' => { listenerName => options.uniq } } if options.any?
      log "haproxy: listener #{listenerName} added..."

    end
  end
  # listerners list is set

  template "#{haproxy['conf_dir']}/haproxy.cfg" do
    source 'haproxy.cfg.erb'
    mode 00644
    owner 'root'
    group 'root'
    variables(
     :listeners => listeners
    )
  end if listeners.any?
  log "haproxy: configured..."

end
