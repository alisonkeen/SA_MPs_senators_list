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
require 'colorize'

require 'pry'

# This is stopping me from debugging/running
# what do I need it for? 
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'

sa_mps_url = 'https://www2.parliament.sa.gov.au/Internet/DesktopModules/Memberlist.aspx'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('table table table tr').css('a[href*="MemberDrill"]').each do |a|
    puts a.to_s
#    mp_url = URI.join url, tr.attr('href')
#    scrape_person(a.text, mp_url)
  end
end

 def scrape_person(name, url)
   noko = noko_for(url)
   data = { 
     id: url.to_s.split("/").last.sub('senator-',''),
     name: name.sub('Senator ', ''),
     image: noko.css('img[src*="/Senators/"]/@src').text,
     source: url.to_s,
   }
   data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
   ScraperWiki.save_sqlite([:id], data)
end

scrape_list(sa_mps_url)
