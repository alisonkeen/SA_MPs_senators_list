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

   noko = noko_for(url)

   #reset vars for each MP
   electorate_name = nil, which_party = nil, which_house = nil
   email_address = nil
   
   puts "\nName: " + mp_name.to_s

   #Image is located in a different place to other info
   image_tag = noko.css('img[src*="PersonImage"]')[0]
   image_src = URI.join url, image_tag.attr('src')
   puts "Image: " + image_src.to_s

   # Iterate over the rows of general info and try and
   # identify specific information
   info_rows = noko.css('table table table tr')
   info_rows.each do |row|

     #Reset variables for each row
     label = nil, cell_content = nil
     info_cells = row.css('td[class*="boxedtext"]')
     next if info_cells[0] == nil  # ignore lines with no "boxedtext"

     label = info_cells[0].text.strip 
     cell_content = info_cells[1].text.strip 

     # Check if line contains Electorate
     if label.to_s == "Electorate" 
        electorate_name = cell_content
	puts "Electorate: " + electorate_name
     end
 
     # Check if it's which house
     if label.to_s == "House" 
        which_house = cell_content
	puts "House: " + which_house
     end

     # Check if line contains MP email
     if label.to_s == "Email" 
        email_address = cell_content
	puts "Email: " + email_address
     end
 
     # Check if line contains MP email
     if label.to_s == "Political Party" 
        which_party = cell_content
	puts "Party: " + which_party
     end
 
   end #end row interation

   data = { 
     id: url.to_s.split("=").last,
     id__saparl: url.to_s.split("=").last,
     full_name: mp_name,
     house: which_house,
     email: email_address,
     image: image_src,
     profile_page: url.to_s,
   }

   data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?

   ScraperWiki.save_sqlite([:id], data)
end

scrape_list(sa_mps_url)

#Testing: just try it on one page first... 
#scrape_person('Frances Bedford', 'https://www2.parliament.sa.gov.au/Internet/DesktopModules/MemberDrill.aspx?pid=543')
