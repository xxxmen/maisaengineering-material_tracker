namespace :mailer do
  desc "Delivers a summary of requests to each planner in the system"
  task :deliver_requests_for_planner => :environment do
    Employee.find(:all, :conditions => ["role = ?", Employee::PLANNING]).each do |planner|
      requests = MaterialRequest.requests_for_planner(planner.id)
      RequestMailer.deliver_requests_for_planner(planner, requests) if planner.email? && requests.size > 0      
    end
  end
end