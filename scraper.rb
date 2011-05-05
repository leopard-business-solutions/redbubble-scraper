#!/usr/bin/env ruby

# Load the RSS parser
require 'feedzirra'

# Load the models
Dir[File.join(File.dirname(__FILE__),"models","*.rb")].each {|file| require file }

feed_url = "http://www.redbubble.com/people/purpleelephant/collections/8442-fine-art-prints.atom"
feed = Feedzirra::Feed.fetch_and_parse(feed_url)

product_exp = /<a([^>]*)products([^>]*)><img([^>]*)\/><\/a>/ # This is used to match images nested in <a> tags where the href points to a product url
product_url_exp = /http:\/\/([^"\/]*\/)*products\/([^"]*)/ # i.e. http://www.redbubble.com/products/configure/5259701-laminated-print
product_image_url_exp = /http:\/\/([^"\/]*\/)*work([^"]*)/ # i.e. http://ih3.redbubble.net/work.6977442.2.flat,550x550,075,f.st-marys-church-bucklebury.jpg

feed.entries.each do |entry|
  photo = Photo.new
  photo.title = entry.title
  photo.published_at = entry.published
  photo.categories = entry.categories

  photo.products = []

  while product_tag = product_exp.match(entry.content)
    product_tag = product_tag.to_s

    product = Product.new
    product.url = product_url_exp.match(product_tag) # Grab the product URL
    product.image_url = product_image_url_exp.match(product_tag) # Grab the product's image url 
    
    photo.products << product
    entry.content.gsub!(product_tag, '') # Delete this tag so we dont trip over it again
  end
end
