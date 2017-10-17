require 'google_drive'
require 'rubygems'
require 'open-uri'
require 'nokogiri'

def send_drive(jtm)
	session = GoogleDrive::Session.from_config("config.json")
	ws = session.spreadsheet_by_key("1Z4VfBYF-wAgsj5au5xtgOPsUtPsxYtV9MM-Mc-8qHoU").worksheets[0]

	jtm.each do |row|
		ws.insert_rows(ws.num_rows + 1, [[row[:ville], row[:email]]])
	end
	ws.save
end
 
def get_all_email_from_72(url, mairie)
	my_emails = []
	final_hash = []
	url.each do |page_url|
		doc = Nokogiri::HTML(open(page_url))
		a = doc.xpath('.//*[@class = "Style22"]')
		my_emails << a[11].text[1..-1]
	end
	final_hash = mairie.zip(my_emails).map { |ville, email| {ville: ville, email: email} }
	send_drive(final_hash)
end

def get_all_urls_of_72
	tabl = []
	mairie_name = []
	doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/sarthe.html"))
	doc.xpath('.//*[@class="lientxt"]/@href').each do |node|
		tabl << "http://annuaire-des-mairies.com/#{node.text[1..-1]}"
	end

	doc = Nokogiri::HTML(open("http://annuaire-des-mairies.com/sarthe-2.html"))
	doc.xpath('.//*[@class="lientxt"]/@href').each do |node|
		tabl << "http://annuaire-des-mairies.com/#{node.text[1..-1]}"
	end

	doc = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/sarthe.html"))
	doc.xpath('.//*[@class="lientxt"]').each do |name_mairie|
		mairie_name << name_mairie.text
	end

	doc = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/sarthe-2.html"))
	doc.xpath('.//*[@class="lientxt"]').each do |name_mairie|
		mairie_name << name_mairie.text
	end
	get_all_email_from_72(tabl, mairie_name)
end
get_all_urls_of_72()



