#!/usr/bin/env ruby

# Load the RSS parser
require 'feedzirra'

# Load the URI parser
require 'uri' 

# Load the HTTP library
require 'net/http'

# Load the models
Dir[File.join(File.dirname(__FILE__),"models","*.rb")].each {|file| require file }

# Constants
FEED_URL = "http://www.redbubble.com/people/purpleelephant/collections/8442-fine-art-prints.atom"
DEFAULT_IMAGE_SIZE = "550x550" # At the moment, this is the image size used in the RSS feed
PREFERED_IMAGE_SIZE = "800x800" # This is currently the maximum image size supported by redbubble

# Regular Expressions
PRODUCT_EXP = /<a([^>]*)products([^>]*)><img([^>]*)\/><\/a>/ # This is used to match images nested in <a> tags where the href points to a product url
PRODUCT_URL_EXP = /http:\/\/([^"\/]*\/)*products\/([^"]*)/ # i.e. http://www.redbubble.com/products/configure/5259701-laminated-print
PRODUCT_IMAGE_URL_EXP = /http:\/\/([^"\/]*\/)*work([^"]*)/ # i.e. http://ih3.redbubble.net/work.6977442.2.flat,550x550,075,f.st-marys-church-bucklebury.jpg


# Hmmm what to call this method? fetch doesn't feel very descriptive
def fetch
  feed = Feedzirra::Feed.fetch_and_parse(FEED_URL)

  # Loop counters
  product_image_counter = 0
  photo_counter = 0

  # Loop over the feed entries creating a new photo object for each..
  feed.entries.each do |entry|
    photo = Photo.new
    photo.title = entry.title
    photo.published_at = entry.published
    photo.categories = entry.categories

    download_image(entry.links[1].gsub(DEFAULT_IMAGE_SIZE, PREFERED_IMAGE_SIZE), "photos", photo_counter)

    photo.products = []

    # Run a regex match loop getting all of the products embedded in the entriy's content
    while product_tag = PRODUCT_EXP.match(entry.content)
      product_tag = product_tag.to_s

      product = Product.new

      # Grab the product URL
      product.url = PRODUCT_URL_EXP.match(product_tag).to_s 

      # Grab the product's image url 
      product.image_url = PRODUCT_IMAGE_URL_EXP.match(product_tag).to_s 

      download_image(product.image_url, "products", product_image_counter)

      product_image_counter += 1

      photo.products << product

      # Delete this tag so we dont trip over it again
      entry.content.gsub!(product_tag, '') 
    end
    photo_counter += 1
  end
end

# Go download image from url, into directory using id as the unique filename
def download_image(url, directory, id)
  uri = URI.parse(URI.escape(url))

  begin
    Net::HTTP.start(uri.host) do |http|
      resp = http.get(uri.path)
      begin
        f = open(File.join(File.dirname(__FILE__), "images", directory, "#{id}.jpg"), "wb")
        http.request_get(uri.path) do |resp|
          resp.read_body do |segment|
            f.write(segment)
          end
        end
      ensure
        f.close
      end
    end
  rescue => e
    puts "Error downloading #{url}"
    puts e.message
  end
end

# Lets get this show on the road!
fetch
