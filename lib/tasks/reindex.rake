namespace :db do
  desc "Reindexes ferret"
  task :reindex => :environment do
    [Cart, Company, Employee, Unit, Vendor, Reference, InventoryItem, MaterialRequest, Order, OrderedLineItem].each do |klass|
      klass.rebuild_index
    end
  end
end