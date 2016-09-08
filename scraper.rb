#!/bin/env ruby
# encoding: utf-8


# This script started off as a shamelessly plagiarized version of the Popolo/ EveryPolitician Virgin Islands example scraper (thanks, guys!!)
# Hopefully it isn't too similar but it gave me a very readable starting point, as a ruby beginner. :) 
# - Alison

# Original is here: 
# https://github.com/tmtmtmtm/us-virgin-islands-legislature/blob/master/scraper.rb

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

# This is stopping me from debugging/running
# what do I need these for? 

# require 'colorize'
# require 'pry'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'

sa_mps_url = 'https://www2.parliament.sa.gov.au/Internet/DesktopModules/Memberlist.aspx'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('table table table tr').css('a[href*="MemberDrill"]').each do |a|
    mp_url = URI.join url, a.attr('href')
    scrape_person(a.text, mp_url)
  end
end

 def scrape_person(mp_name, url)
   puts mp_name.to_s
   noko = noko_for(url)
   
   image_tag = noko.css('img[src*="PersonImage"]')[0]
   image_src = URI.join url, image_tag.attr('src')

   puts "\nImage: " + image_src.to_s
   
   data = { 
     id: url.to_s.split("=").last,
     name: mp_name,
     image: image_src,
     source: url.to_s,
   }
   data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?

   ScraperWiki.save_sqlite([:id], data)
end

scrape_list(sa_mps_url)
