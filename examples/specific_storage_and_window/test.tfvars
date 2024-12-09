administrator_login = "testadmin"
storage = {
  io_scaling_enabled = false
  iops               = 1000
  size_gb            = 22
  auto_grow_enabled  = true
}

maintenance_window = {
  day_of_week  = 0
  start_hour   = 2
  start_minute = 0
}
