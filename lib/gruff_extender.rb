# Extends Gruff::Base, which allows you to specify @d for the draw object, and @base_image for the actual image.
module GruffExtender
      
    # Allows you to draw text anywhere on the image  
    def draw_text_on_image(x,y,text)
       @d = @d.text(x,y,text)
    end
    
    def font_size(size)
        @d = @d.pointsize(size)
    end
    
    # Adds another image from image_path to the current Gruff image.
    def add_image(image_path,x,y,resize_x=nil,resize_y=nil)
      src = Magick::Image.read(image_path)[0]
      if resize_x != nil && resize_y != nil
        src = src.resize(resize_x,resize_y)
      end
      @base_image = @base_image.composite(src, x, y, Magick::OverCompositeOp)
    end 
    
    def theme_bp
      # Colors
      @green = '#339933'
      @purple = '#cc99cc'
      @blue = '#336699'
      @yellow = '#FFF804'
      @red = '#ff0000'
      @orange = '#cf5910'
      @black = 'black'
      @colors = [ @green, @blue, @red, @purple, @orange, @black]

      self.theme = {
        :colors => @colors,
        :marker_color => 'black',
        :font_color => 'black',
        :background_colors => ['#d1edf5', 'white']
      }
    end
    
end