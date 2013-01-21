class Link < ActiveRecord::Base
    generator_for :name, :start => 'Link_100' do |prev|
        prev.succ
    end
    generator_for :url, :start => 'www.google.com'
end
