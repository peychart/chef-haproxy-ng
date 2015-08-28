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
    <td><tt>['chef-haproxy-ng']['listener']</tt></td>
    <td>Hash</td>
    <td>Sets the listeners</td>
    <td><tt>{}</tt></td>
  </tr>
</table>

## Usage

 Configuration can be defined in a data bag "service" (see: https://github.com/peychart/chef-serviceAttributes) where each provided service is described.

 This cookbook must be re-executed on each existing node when adding a new node to the cluster. All nodes found in the same dnsdomainname (search in ohai database) are added.

eg:
<pre>
{
  "id": "haproxyForSquid",
  "haproxy": {
    "balance": "roundrobin",
    "listener": {			// Sets all listeners defining this cluster...
      "admin": {
        "bind": "squid:31280",
        "option-": [			// '-' means the word "option" will not appear in the conf for those options...
          "mode http",
          "stats uri /",
          "stats refresh 5s"
        ]
      },
      "squid": {			// Squid listerner:
        "bind": "squid:3128",
        "maxconn": 30000,
        "grace": 10000,
        "#http-check": "expect rstatus 200|400|407",
        "option": [
          "httpchk HEAD http://squid:80/ HTTP/1.0",
          "allbackups"
        ],
        "pool_member": {		// Members of this listener (all the nodes with this same definition 'squid' found in the ohai database will be added).
          "bind": 3128,
          "option": "check inter 10s",
          "toriki.srv.gov.pf": [	// If the current dnsdomainname is "toriki.srv.gov.pf": add this list of foreign members...
            "server squid1.a1a2.srv.gov.pf squid1.a1a2.srv.gov.pf:3128 check inter 10s backup",
            "server squid2.a1a2.srv.gov.pf squid2.a1a2.srv.gov.pf:3128 check inter 10s backup"
          ],
          "a1a2.srv.gov.pf": [		// If the current dnsdomainname is "a1a2.srv.gov.pf": add this list of foreign members...
            "server squid1.toriki.srv.gov.pf squid1.toriki.srv.gov.pf:3128 check inter 10s backup",
            "server squid2.toriki.srv.gov.pf squid2.toriki.srv.gov.pf:3128 check inter 10s backup"
          ]
        }
      },
      "squidGuard": {
        "bind": "squid:80",
        "pool_member": {
          "bind": 8080,
          "option": "check inter 60s",
          "toriki.srv.gov.pf": [
            "server squid1.a1a2.srv.gov.pf squid1.a1a2.srv.gov.pf:8080 check inter 10s backup",
            "server squid2.a1a2.srv.gov.pf squid2.a1a2.srv.gov.pf:8080 check inter 10s backup"
          ],
          "a1a2.srv.gov.pf": [
            "server squid1.toriki.srv.gov.pf squid1.toriki.srv.gov.pf:8080 check inter 10s backup",
            "server squid2.toriki.srv.gov.pf squid2.toriki.srv.gov.pf:8080 check inter 10s backup"
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
    "service": [
      "haproxyForSquid"
    ]
  },
  "run_list": [
    "recipe[chef-serviceAttributes::default]",
    "role[squidService]",			// See: https://github.com/peychart/chef-squid
    "recipe[chef-haproxy-ng::default]",
    "recipe[keepalived::default]"
  ]
}
```

## License and Authors

Author:: PE, pf. (<peychart@mail.pf>)
