#! /usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'mechanize'

downloader = Mechanize.new
downloader.pluggable_parser.default = Mechanize::Download

print "Enter Soundcloud username: "
username = gets.chomp

print "Enter how many pages to scrape: "
count = gets.chomp

urls = {}
base = "http://soundcloud.com/#{username}"

paged_urls = (1..count.to_i).collect do |num|
  "#{base}/tracks?format=html&page=#{num}"
end

paged_urls.each do |page|
  page = Nokogiri::HTML(open(page))
  tunes = page.css('ul.tracks-list li.player')
  tunes.each do |tune|
    title = tune.css('div.info-header h3 a').text
    link  = tune.css('div.actionbar div.actions div.primary a.download')
    next if link.empty?
    urls[title] = "http://soundcloud.com" + link.attr('href')
  end
end

urls.each do |key,value|
  filename = "downloads/#{key}.mp3"

  unless File.exist?(filename)
    puts "Downloading #{key}..."
    downloader.get(value).save(filename)
  else
    puts "Skipped file (already exists)..."
  end
end
