class EventsController < ApplicationController
  def index
    Event.filter(params, current_employee) do
      @events = Event.list(params, :include => [:employee], :order => "events.created_at", :sort => "desc")
    end
  end
end