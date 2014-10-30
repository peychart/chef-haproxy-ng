# chef-haproxy-ng-cookbook

 This chef cookbook allows to configure haproxy ...

## Supported Platforms

 ubuntu/debian

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chef-haproxy-ng']['package']</tt></td>
    <td>String</td>
    <td>haproxy package name</td>
    <td><tt>haproxy</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-haproxy-ng']['user/group']</tt></td>
    <td>String</td>
    <td>user/group of the haproxy process</td>
    <td><tt>haproxy</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-haproxy-ng']['conf_dir']</tt></td>
    <td>String</td>
    <td>directory of the config file</td>
    <td><tt>/etc/haproxy</tt></td>
  </tr>
  <tr>
    <td><tt>['chef-haproxy-ng']['admin']['enable']</tt></td>
    <td>String</td>
    <td>Set or not the stats page file</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

 Configuration can be defined in a data bag "clusters" (see: https://github.com/peychart/chef-nodeAttributes) where each node is described in an item whose id(1) is its fqdn.

 (1): Dots are not allowed (only alphanumeric), substitute by underscores

eg:
<pre>
{
  "id": "ldap2_mydomain",
  "haproxy":{
    "listeners":{
      "ldap_cluster":{
        "pool_members":[
          "ldap2 ldap2.mydomain check"
        ]
      }
    }
  }
}
{
  "id": "ldap_mydomain",
  "haproxy": {
    "bind": "ldap1.mydomain:390",
    "mode": "tcp",
    "balance": "leastconn",
    "listeners": {
      "ldap_cluster": {
        "defaults": nil
      }
    }
  }
}
{
  "id": "ldap1_mydomain",
  "haproxy":{
    "services":{
      "ldap_cluster":[
        "pool_members":[
          "ldap1 ldap1.mydomain check"
        ]
      }
    }
  }
}
</pre>

### chef-haproxy-ng::default

Include `chef-haproxy-ng` in your node's `run_list`:

```json
{
 "override_attributes": {
    "databag_name": "clusters"
  },
  "run_list": [
    "recipe[chef-nodeAttributes::default]",
    "recipe[chef-haproxy-ng::default]"
  ]
}
```

## License and Authors

Author:: PE, pf. (<peychart@mail.pf>)
