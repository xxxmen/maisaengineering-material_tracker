module AttributesFor
  def self.valid(obj, obj_attrs, options = {})
    obj = obj.to_s
    class_name = options.has_key?(:class_name) ? options.delete(:class_name) : obj.camelize
    klass = Object.const_get(class_name)
    
    self.send(:define_method, "valid_" + obj) do |*args|
      attrs = args.first || {}
      obj_attrs.merge(attrs)
    end
  
    self.send(:define_method, "create_" + obj) do |*args|
      attrs = args.first || {}
      klass.create(send("valid_" + obj, attrs))
    end
  
    self.send(:define_method, "new_" + obj) do |*args|
      attrs = args.first || {}
      klass.new(send("valid_" + obj, attrs))
    end
  end

  def self.invalid(obj, obj_attrs, options = {})
    obj = obj.to_s
    class_name = options.has_key?(:class_name) ? options.delete(:class_name) : obj.camelize
    klass = Object.const_get(class_name)
    
    self.send(:define_method, "invalid_" + obj) do |*args|
      attrs = args.first || {}
      obj_attrs.merge(attrs)
    end
  
    self.send(:define_method, "create_invalid_" + obj) do |*args|
      attrs = args.first || {}
      klass.create(send("invalid_" + obj, attrs))
    end
  
    self.send(:define_method, "new_invalid_" + obj) do |*args|
      attrs = args.first || {}
      klass.new(send("invalid_" + obj, attrs))
    end
  end
end
