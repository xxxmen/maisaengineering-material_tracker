class Post
  attr_reader :id
  def save; @id = 1 end
  def new_record?; @id.nil? end
  def name
    @id.nil? ? 'new post' : "post ##{@id}"
  end
  class Nested < Post; end
end
