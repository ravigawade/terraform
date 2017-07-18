rs.initiate()
sleep(18000)
{% for host in groups['tag_role_database'] %}
rs.add("{{ hostvars[host]['ec2_private_ip_address']}}:{{ mongo_port }}")
{% endfor %}
sleep(18000)
cfg = rs.conf()
for (var i=0; i<cfg.members.length; i++) {
        if (cfg.members[i].host  == '{{ hostvars[mongo_master_host]['ec2_private_ip_address'] }}:27017') {
                cfg.members[i].priority = {{ mongo_master_priority }};
        } else {
                cfg.members[i].priority = {{ mongo_standby_priority }};
        }
}
rs.reconfig(cfg)
printjson(rs.status())
