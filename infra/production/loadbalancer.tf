# resource "ncloud_lb" "prod_lb" {
#   name           = "lion-prod-lb"
#   network_type   = "PUBLIC"
#   type           = "NETWORK_PROXY"
#   subnet_no_list = [ncloud_subnet.lb.subnet_no]
# }

# resource "ncloud_lb_target_group" "prod_lb" {
#   name        = "lion-prod-target"
#   vpc_no      = ncloud_vpc.main.vpc_no
#   protocol    = "PROXY_TCP"
#   target_type = "VSVR"
#   port        = 8000
#   health_check {
#     protocol       = "TCP"
#     http_method    = "GET"
#     url_path       = "/admin"
#     port           = 8000
#     cycle          = 30
#     up_threshold   = 2
#     down_threshold = 2
#   }
#   algorithm_type = "RR"
# }

# resource "ncloud_lb_listener" "prod" {
#   load_balancer_no = ncloud_lb.prod_lb.load_balancer_no
#   target_group_no  = ncloud_lb_target_group.prod_lb.target_group_no
#   protocol         = "TCP"
#   port             = 80
# }

# resource "ncloud_lb_target_group_attachment" "prod" {
#   target_group_no = ncloud_lb_target_group.prod_lb.target_group_no
#   target_no_list  = [ncloud_server.prod_be.instance_no]
# }
