class EmailsController < ApplicationController
  def show
    @email = Email.find(params[:id])
    @content = @email.content
    @content.gsub!(/\nTo: /, "<br />To: ")
    @content.gsub!(/\nSubject: /, "<br />Subject: ")
    @content.gsub!(/\nMime-Version: /, "<br />Mime-Version: ")
    @content.gsub!(/<h1>/, "<br /><br /><h1>")
  end
end