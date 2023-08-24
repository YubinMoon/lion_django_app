# resource "ncloud_lb_target_group" "lion_target" {
#   name        = "liontarget"
#   vpc_no      = ncloud_vpc.lion.id
#   protocol    = "PROXY_TCP"
#   target_type = "VSVR"
#   port        = 8000
#   description = "lion django target"
#   health_check {
#     protocol       = "TCP"
#     http_method    = "GET"
#     port           = 8000
#     cycle          = 30
#     up_threshold   = 2
#     down_threshold = 2
#   }
# }

# resource "ncloud_lb_target_group_attachment" "lion_target_server" {
#   target_group_no = ncloud_lb_target_group.lion_target.target_group_no
#   target_no_list  = [ncloud_server.be.id]
# }

# resource "ncloud_lb" "lion_lb" {
#   name           = "lion-lb"
#   network_type   = "PUBLIC"
#   type           = "NETWORK_PROXY"
#   subnet_no_list = [ncloud_subnet.be_lb.subnet_no]
# }

# resource "ncloud_lb_listener" "lion_lb_listener" {
#   load_balancer_no = ncloud_lb.lion_lb.load_balancer_no
#   protocol         = "TCP"
#   port             = 80
#   target_group_no  = ncloud_lb_target_group.lion_target.target_group_no
# }

