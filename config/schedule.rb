# frozen_string_literal: true

Process.setproctitle("zd_helper_schedule")
File.open("./tmp/zd_helper_schedule.pid", "w") do |f|
  f << Process.pid
end

require './application'

scheduler = Rufus::Scheduler.new

scheduler.every '5m', name: "Check tickets" do
  Zendesk::Snitcher::Pattern::Default.new.go
end

scheduler.join
