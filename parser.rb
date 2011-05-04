require 'feedzirra'

feed_url = "http://www.redbubble.com/people/purpleelephant/collections/8442-fine-art-prints.atom"
feed = Feedzirra::Feed.fetch_and_parse(feed_url)

exp = /"http:\/\/([^"\/]*\/)*configure\/([^"]*)"/ # i.e. http://www.redbubble.com/products/configure/5259701-laminated-print

feed.entries.each do |entry|
  while e = exp.match(entry.content)
    e = e.to_s.gsub(/"/, '') # Strip out the quotes
    puts e
    entry.content.gsub!(e.to_s, '')
  end
end
