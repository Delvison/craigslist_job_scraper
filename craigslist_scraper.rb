require 'mechanize'


def find_jobs(keywords, url)
  begin
    # initialize mechanize
    mech = Mechanize.new{ |agent|
      agent.user_agent_alias = "Mac Safari"
    }

    # visit URL
    page = mech.get(url)

    # parse body
    parse_page = Nokogiri::HTML(page.body)

    # calculate how many results we have seen
    total = parse_page.css('.buttons').css('.button').css('.totalcount').text
    total = total[0..(total.length/2)-1]
    current = parse_page.css('.buttons').css('.button').css('.rangeTo').text
    current = current[0..(current.length/2)-1]
    puts "#{current} / #{total} ------------------------------- #{url}"

    # process each row
    rows = parse_page.css('.content').css('.result-row')
    rows.each do |row|
      a = row.search('.hdrlnk')
      date = row.search('time.result-date')[0]['datetime']
      link = join_link("https://newyork.craigslist.org", a[0]['href'])
      title = a.text.downcase
      check = keywords.any? { |k| title.include? k }
      # check, title = hilight_match(keywords, title)
      if check
        printf("- %s\n	%s\n	%s\n", title, link, date)
      end
    end


    unless current.to_i == total.to_i
      next_page = parse_page.search('a.button.next')[0]['href']
      sleep(rand(20))
      find_jobs(keywords,  "https://newyork.craigslist.org" << next_page)
    end

  rescue Net::HTTP::Persistent::Error
    puts 'Connection refused for ' << url
  end
end

def join_link(base, link)
   return (link.include? base) ? link : (base << link)
end

def hilight_match(keywords, title)
	begin
		blue = "\033[1;34m"
		endc = "\033[0;0m"
		keywords.each do |k|
			if title.include? k
				x = title.index(k)-1
				y = x+blue.length
				title = title[0..x-1] << blue << title[x..y] << endc << title[y+1..-1]
				return true, title
			end
		end
		return false, title
	rescue TypeError
		return false, title
	end
end


keywords = ["nodejs", 
						"java",
						"programmer",
						"coder",
						"stack",
						"developer", 
						"ruby",
						"backend",
						"python",
						"software",
						"php"]
find_jobs(keywords,'https://newyork.craigslist.org/search/jjj')
find_jobs(keywords,'https://newyork.craigslist.org/search/sof')
find_jobs(keywords,'https://newyork.craigslist.org/search/ggg')
