require 'open-uri'
require 'bundler/setup'
Bundler.require

opts = Slop.parse do |o|
  o.string '-ri', '--resources-info', 'path to json file with images information'
  o.string '-ki', '--kind-of-image', 'attribute inside each resource description to fetch image information'
  o.bool '-sd', '--skip-download', 'skip download process'
  o.on '--version', 'print the version' do
    puts Slop::VERSION
    exit
  end
end

class ImageOptimizer
  def initialize(resources_info, kind_of_image, skip_download)
    capture_exception do
      @skip_download = skip_download
      @kind_of_image = kind_of_image
      @resources_info = JSON.parse(open(resources_info).read)
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
    download_requested_images unless @skip_download
    optimize
  end

  def images_info
    @images_info = @resources_info.map do |resource|
                    image_src = resource['mainImage'][@kind_of_image]
                    image_name = image_src.split('/').last
                    { name: image_name, src: image_src }
                  end
  end

  def optimize
    images_info.each do |image_info|
      optimized_image_name = image_info[:name]
      print "optimizing #{image_info[:name]}..."
      MiniMagick::Tool::Convert.new do |convert|
        convert << "./original_images/#{image_info[:name]}"
        convert.merge! ["-resize", "2000x", "-strip", "-quality", "100"]
        convert << "./optimized_images/#{optimized_image_name}"
      end
      print "\t-> #{optimized_image_name} done!\n"
    end
  end

  def download_requested_images
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

image_optimizer = ImageOptimizer.new(opts[:resources_info], opts[:kind_of_image], opts[:skip_download])
image_optimizer.process