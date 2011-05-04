exp = /http:\/\/([^"\/]*\/)*configure\/([^"]*)/

search_string = %q{some big load of junk &lt;a href="http://redbubble.com/configure/10000" a/&gt; some other load of junk &lt;a href="http://redbubble.com/configure/10001" a/&gt; }

while e = exp.match(search_string)
  puts e
  search_string.gsub!(e.to_s, '')
end
