require 'open-uri'
require 'bundler/setup'
Bundler.require

opts = Slop.parse do |o|
  o.string '-ri', '--resources-info', 'path to json file with images information'
  o.string '-ki', '--kind-of-image', 'attribute inside each resource description to fetch image information'
  o.string '-w', '--width', 'width to resize'
  o.string '-h', '--height', 'height to resize'
  o.string '-q', '--quality', 'quality of image to resize'
  o.string '-e', '--extension', 'extension of the output image'
  o.bool '-sd', '--skip-download', 'skip download process'
  o.on '--version', 'print the version' do
    puts Slop::VERSION
    exit
  end
end

class ImageOptimizer
  def initialize(options)
    default_options = {
      extension: 'png',
      width: '2000',
      quality: "100",
      kind_of_image: 'original',
      skip_download: false
    }

    capture_exception do
      options = options.to_h.delete_if { |_, value| value.nil? }
      options = default_options.merge(options)
      @options = options
      if options[:resources_info]
        @resources_info = JSON.parse(open(options[:resources_info]).read)
      else
        @resources_info = nil
      end
    end
  end

  def capture_exception
    yield
  rescue => e
    puts "There was an error initializing ImageOptimizer: #{e.message}\n\n"
    e.backtrace.each { |trace| puts "\t#{trace}" }
    exit 0
  end

  def process
    download_requested_images unless @options[:skip_download]
    optimize
  end

  def images_info
    @images_info =
      if @resources_info
        send(:images_info_by_json_file)
      else
        send(:images_info_by_folder)
      end
  end

  def images_info_by_folder
    Dir["#{Dir.pwd}/original_images/*"].map do |image_src|
      { name: image_src.split('/').last, src: image_src }
    end
  end

  def images_info_by_json_file
    @resources_info.map do |resource|
      image_src = resource['mainImage'][@options[:kind_of_image]]
      image_name = image_src.split('/').last
      { name: image_name, src: image_src }
    end
  end

  def optimize
    images_info.each do |image_info|
      optimized_image_name =
        if @options[:kind_of_image]
          image_info[:name].split('.').first + ".#{@options[:extension]}"
        else
          image_info[:name]
        end
      print "optimizing #{image_info[:name]}..."
      MiniMagick::Tool::Convert.new do |convert|
        convert << "./original_images/#{image_info[:name]}"
        convert.merge! ["-resize", "#{size}", "-strip", "-quality", "#{@options[:quality]}"]
        convert << "./optimized_images/#{optimized_image_name}"
      end
      print "\t-> #{optimized_image_name} done!\n"
    end
  end

  def size
    [@options[:width], 'x', @options[:height]].compact.join('')
  end

  def download_requested_images
    return unless @resources_info
    images_info.each do |image_info|
      image = open(image_info[:src]) do |image|
        File.open("./original_images/#{image_info[:name]}", 'wb') do |local_image|
          print "Downloading ./original_images/#{image_info[:name]}..."
          local_image.puts image.read
          print "\t. . . downloaded!\n"
        end
      end
    end
  end
end

image_optimizer = ImageOptimizer.new(opts)
image_optimizer.process