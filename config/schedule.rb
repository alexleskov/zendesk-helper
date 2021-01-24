# frozen_string_literal: true

Process.setproctitle("zd_helper_schedule")
File.open("./tmp/zd_helper_schedule.pid", "w") do |f|
  f << Process.pid
end

require './application'

scheduler = Rufus::Scheduler.new

scheduler.every '3m', name: "Check tickets" do |_job|
  Zendesk::Snitcher::Pattern::Default.new.run
end

scheduler.join
