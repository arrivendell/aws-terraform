resource "aws_elasticache_replication_group" "url_shortener" {
  replication_group_id          = "url-shortener"
  replication_group_description = "Redis cluster for url_shortener app"

  node_type            = "cache.t2.micro"
  port                 = 6379
  parameter_group_name = "default.redis3.2.cluster.on"

  subnet_group_name = "${aws_elasticache_subnet_group.url_shortener.name}"

  automatic_failover_enabled = true

  security_group_ids = ["${aws_security_group.allow_ec2_instances_sg.id}"]

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 1
  }
}

resource "aws_elasticache_subnet_group" "url_shortener" {
  name       = "url-shortener-cache-subnet"
  subnet_ids = ["${aws_subnet.url_shortener_1b.id}", "${aws_subnet.url_shortener_1a.id}"]
}
