#!/usr/bin/ruby

require 'httparty'
require 'digest/sha1'
require 'nokogiri'
require 'net/http'


#config this to make it work
email = ""
password = ""
appid = ""
apikey = ""



ARGV.each do |linkfile|
  file = File.open(linkfile).read
  file.each_line do |line|

    # reauthenticate
    signature = Digest::SHA1.hexdigest (email + password + appid + apikey)
    sesh_token = HTTParty.get("https://www.mediafire.com/api/user/get_session_token.php?email=#{email}&password=#{password}&application_id=#{appid}&signature=#{signature}&version=2.13")
    puts "---- session token (begin ) ----"
    puts sesh_token.body
    puts "---- session token (end ) ----"
    puts "\n"
    doc = Nokogiri::HTML(sesh_token.body)
    sessionkey = doc.css('response session_token').first.content

    #get links
    string = "http://www.mediafire.com/api/file/get_links.php?link_type=direct_download&session_token=#{sessionkey}&quick_key=#{line.strip}&response_format=xml"
    apilink = HTTParty.get(string)

    puts "---- ddl api call url (begin) ----"
    puts string
    puts "---- ddl api call url (end) ----"
    puts "\n"

    apilinkdoc = Nokogiri::HTML(apilink.body)

    puts "---- api link doc body (begin) ----"    
    puts apilink.body.to_s
    puts "---- api link doc body (begin) ----"
    puts "\n"

    address = apilinkdoc.css('response links link direct_download')
    
    puts "---- quick_key (begin) ----"
    puts "#{line.strip}"
    puts "---- quick_key (end) ----"
    puts "\n"

    puts "---- address (begin) ----"
    puts address.inspect
    puts "---- address (end) ----"
    puts "\n"
    
    whatever = address.first.content
    filename = address.split("/").last
    uri = URI(address)

    `wget #{filename}`
  end
end


