# -*- coding: utf-8 -*-
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'json'

#latest
#url = "http://developer.appcelerator.com/apidoc/mobile/latest/"

# 2.1
url_root = "http://docs.appcelerator.com/titanium/2.1/"
url_api  = "#!/api"

# 2.1.json url
url_json = "http://docs.appcelerator.com/titanium/data/2.1.0/api.json"

# 2.1.json file
file_json = ".\\api.json"

# read
buffer = open(file_json).read

# list
list = Array.new

# convert JSON data into a hash
result = JSON.parse(buffer)
result.each do | key, val |

  class_root = ""
  class_name = ""
  persons = key.split(".")
  persons.each do | person |
    if person == "Global" || person.length == 0
      next
    end
    if class_name.length == 0
      class_name = "#{person}"
    else
      class_name += "['#{person}']"
    end
    list.push("\t#{class_name} = function(){};")
  end

  methods = val['methods']
  methods.each do | method |
    if method != nil
      ret = method['returns']
      if ret.instance_of?(Hash)
        type = ret['type']
      else
        type = ret[0]["type"]
      end

      if type == "void"
        list.push("\t#{class_name}['#{method['name']}'] = function(){};")
      else
        list.push("\t#{class_name}['#{method['name']}'] = function(){ return new #{type}; };")
      end

    end
  end
end

list.uniq!
list.sort!


puts "(function () {"
puts "\tif (typeof Titanium !== 'undefined') return;"
puts "\tif (typeof Ti !== 'undefined') return;"
puts list
puts "\tTi = Titanium;"
puts "})(this);"

