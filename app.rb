$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sass'
require 'lib/authorization'
require 'carrierwave'
require 'carrierwave/datamapper'
require 'mini_magick'
require 'data_mapper'
enable :sessions

get '/css/main.css' do
	content_type 'text/css', :charset => 'utf-8'
	scss(:"css/main")
end

configure :development do
	require 'dm-sqlite-adapter'
	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/palmarinha.db")
end

configure :production do
	require 'mysql'
	require 'dm-mysql-adapter'
	DataMapper::setup(:default, "mysql://root:hash2014@127.0.0.1/palmarinha")
end

DataMapper::Property::String.length(255)
DataMapper::Model.raise_on_save_failure = true 

helpers do
	include Sinatra::Authorization
end

class Hotel
	include DataMapper::Resource
	property :id,				Serial
	property :name,			String
	property :desc,			Text
	property :location,		String
	property :url,				String
	property :price,			String
	property :thumbnail,		String
	property :document,		String
	property :is_active, 	Boolean, :default => true
	property :created_at,	DateTime
	property :updated_at,	DateTime

	def handle_upload(file, hotelid)
		path = File.join(Dir.pwd, "/public/hotels/images", hotelid + "-" + file[:filename].downcase.gsub(" ", "-"))
		File.open(path, "wb") do |f|
			f.write(file[:tempfile].read)
		end	
	end
	
	

	def generate_thumb(file, hotelid)
		path = File.join(Dir.pwd, "/public/hotels/images", hotelid + "-" + file[:filename].downcase.gsub(" ", "-"))
		image = MiniMagick::Image.open(path)
		image.resize "500x800"
		image.write Dir.pwd + "/public/hotels/images/thumbs/" + hotelid + "-" + file[:filename].downcase.gsub(" ", "-")
	end

	def is_active=(switch)
		if switch == "on" || switch == "true"
			super true
		else
			super false
		end
	end
end

def upload_document(file)
	path = File.join(Dir.pwd, "/public/hotels/documents/" + file[:filename].downcase.gsub(" ", "-"))
	File.open(path, "wb") do |f|
		f.write(file[:tempfile].read)
	end	
end

class Special
	include DataMapper::Resource
	property :id,			Serial
	property :offer_img,	String
	property :offer_doc,	String
	property :is_active,	Boolean
	property :created_at,	DateTime
	property :updated_at,	DateTime

	def handle_upload(file, offerid, doctype)
		doctype = "/" + doctype unless doctype == ""
		path = File.join(Dir.pwd, "/public/hotels/specials" + doctype, offerid + "-" + file[:filename].downcase.gsub(" ", "-"))
		File.open(path, "wb") do |f|
			f.write(file[:tempfile].read)
		end	
	end

	def is_active=(switch)
		if switch == "on" || switch == "true"
			super true
		else
			super false
		end
	end

end

DataMapper.auto_upgrade!

get '/reset/?:reqtype?' do
	require_admin

	@reqtype = params[:reqtype]
	case @reqtype
	when 'yes'
		DataMapper.auto_migrate!
		DataMapper.finalize
		halt 'Done <br />Redirect to <a href="/" class="btn btn-primary btn-large">home</a> page'
	else
		halt 'Are you sure you want to reset DB?<br /><a href="/reset/yes" class="btn btn-primary btn-large">Yes Reset</a><br /><a href="/" class="btn btn-primary btn-large">No go to home page</a>'
	end
end

before do
	@page_title = "Palmarinha Holidays"
	@body_class = ""
end


get '/' do
	@page_title = "#{@page_title} | Home"
	@body_class += " home"
	@bg_img = "home-banner"
	@controls = :_home_controls
	erb :home
end

get '/membership' do
	@page_title += " | Members"
	@body_class += " members-page"
	erb :membership
end

get '/member-area' do
	if session[:member] == true
		@page_title += " | Members Area (Private)"
		@body_class += " members-area"
		@special = Special.last
		@hotels = Hotel.all
		erb :member_area
	else
		redirect to('/membership')
	end
end

get '/frequently-asked-questions' do
	erb :faqs
end

get '/about' do
	erb :about
end

get '/contact' do
	erb :contact
end

post '/login' do
	if params[:pass] == 'abc'
		session[:member] = true
		redirect to('/member-area')
	else
		redirect to('/')
	end
end

post '/logout' do
	session[:member] = false
	redirect to('/')
end

get '/hotel/new' do
	require_admin

	@page_title += " | New Hotel"
	@body_class += " new-hotel"
	erb :new_hotel
end

get '/hotel/:id/edit' do
	@hotel = Hotel.get(params[:id])
	
	if @hotel
		erb :edit_hotel
	else
		redirect('/')
	end
end

put '/hotels' do
	require_admin

	@hotel = Hotel.get(params[:hotel][:id])
	@updateparams = params[:hotel]

	@thumbnail = params[:hotel][:thumbnail]
	@document = params[:hotel][:document]

	unless @thumbnail.nil?
		@updateparams[:thumbnail] = @hotel.id.to_s + "-" + @thumbnail[:filename].downcase.gsub(" ", "-")
	end
	
	unless params[:hotel][:document].nil?
		@updateparams[:document] = params[:hotel][:document][:filename].downcase.gsub(" ", "-")
	end

	if @hotel.update(@updateparams)
	
		unless @document.nil?
			upload_document(@document)
		end
		
		unless @thumbnail.nil?
			@hotel.handle_upload(@thumbnail, @hotel.id.to_s)
			@hotel.generate_thumb(@thumbnail, @hotel.id.to_s)
		end
		
		redirect "/admin"
	else
		redirect back
	end

end

post '/hotels' do
	require_admin
	newhotel = params[:hotel]
	hotel = Hotel.new(newhotel)
	
	if !params[:hotel][:thumbnail].nil?
		hotel.thumbnail = params[:hotel][:thumbnail][:filename].downcase.gsub(" ", "-")
	end
	
	if !params[:hotel][:document].nil?
		hotel.document = params[:hotel][:document][:filename].downcase.gsub(" ", "-")
	end
	
	if hotel.save
		if !params[:hotel][:document].nil?
			upload_document(params[:hotel][:document])
		end
		if !params[:hotel][:thumbnail].nil?
			hotel.handle_upload(params[:hotel][:thumbnail], hotel.id.to_s)
			hotel.generate_thumb(params[:hotel][:thumbnail], hotel.id.to_s)
			hotel.update(:thumbnail => hotel.id.to_s + "-" + hotel.thumbnail)
		end
		redirect "/admin"
	else
		redirect back
	end
end

# Create Action
post '/specials' do
	require_admin
	new_special = params[:special]
	new_special[:is_active] = "" unless !new_special[:is_active].nil? # if no value is present for is_active set false
	special = Special.new(new_special)

	special.offer_img = params[:special][:offer_img][:filename].downcase.gsub(" ", "-")
	special.offer_doc = params[:special][:offer_doc][:filename].downcase.gsub(" ", "-")

	if special.save
		special.handle_upload(params[:special][:offer_img], special.id.to_s, "")
		special.handle_upload(params[:special][:offer_doc], special.id.to_s, "document")
		special.update(:offer_img => special.id.to_s + "-" + special.offer_img, :offer_doc => special.id.to_s + "-" + special.offer_doc)
		redirect "/admin"
	else
		redirect back
	end
end

# Update Action
put '/specials' do
	require_admin
	@special = Special.get(params[:special][:id])
	update_special = params[:special]

	update_special.each_pair {|k,v| update_special[k] = nil if v.empty? }
	
	offer_img = params[:special][:offer_img] unless params[:special][:offer_img].nil?
	offer_doc = params[:special][:offer_doc] unless params[:special][:offer_doc].nil?
	
	update_special[:offer_img] = @special.id.to_s + "-" + params[:special][:offer_img][:filename].downcase.gsub(" ", "-") unless params[:special][:offer_img].nil?
	update_special[:offer_doc] = @special.id.to_s + "-" + params[:special][:offer_doc][:filename].downcase.gsub(" ", "-") unless params[:special][:offer_doc].nil?

	@special.handle_upload(offer_img, @special.id.to_s, "") unless offer_img.nil?
	
	@special.handle_upload(offer_doc, @special.id.to_s, "document") unless offer_doc.nil?
	

	if @special.update(update_special)
		redirect "/admin"
	else
		redirect back
	end
end

get '/admin' do	
	require_admin
	
	@page_title += " | Palmarinha Admin"
	@body_class += " admin"
	@hotels = Hotel.all
	@special = Special.last
	erb :admin
end

get '/special/new' do	
	require_admin
	
	@page_title += " | Palmarinha Admin"
	@body_class += " specials"
	erb :new_special
end

get '/special/:id/edit' do	
	require_admin
	
	@page_title += " | Palmarinha Admin"
	@body_class += " specials"

	@special = Special.get(params[:id])

	erb :edit_special
end

delete '/hotel/:id' do
	require_admin
	@hotel = Hotel.get(params[:id])

	if @hotel.destroy!
		redirect '/admin'
	else
		redirect '/'
	end	
end

delete '/special/:id' do
	require_admin
	@special = Special.get(params[:id])

	if @special.destroy!
		redirect '/admin'
	else
		redirect '/'
	end	
end

post '/request-membership' do
	require 'pony'
	#Pony.options = { :from => params[:member][:name] }
	Pony.mail(
		:from => params[:member][:name],
		:to => 'info@palmarinha-holidays.com',
		:subject => "Membership Request",
		:html_body => params[:member][:name] + " from " + params[:member][:city] + " wishes to be a member <br /> Contact by phone: " + params[:member][:phone] + "<br /> by email: " + params[:member][:eadd],
		:via => :smtp,
		:via_options => {
			:address              => 'smtp.sendgrid.net', 
	        :port                 => '587', 
	        :user_name            => 'hashcookies', 
	        :password             => 'Nor1nderchqMudi', 
	        :authentication       => :plain
		}
	)
	redirect '/membership'
end

# Book vacation
post '/book' do
	require 'pony'
	name = params[:book][:name]
	hotel = Hotel.get(params[:book][:hotel_id])
	message = "<br />Message: " + params[:book][:mailbody] unless params[:book][:mailbody].nil?
	body = name + " wishes to book: " + hotel.name + " <br />Check-In: " + params[:book][:check_in] + "<br />Check-Out: " + params[:book][:check_out] + "<br />Contact by email: " + params[:book][:eadd] + message
	Pony.mail(
		:from => 'milind@hashcooki.es',
		:to => 'customerservices@palmarinha-holidays.com',
		:subject => "Vacation Booking",
		:html_body => body,
		:via => :smtp,
		:via_options => {
			  :address              => 'smtp.sendgrid.net', 
	        :port                 => '587', 
	        :user_name            => 'hashcookies', 
	        :password             => 'Nor1nderchqMudi', 
	        :authentication       => :plain
		}
	)
	redirect '/member-area'
end



post '/support-request' do
	require 'pony'
	name = params[:name]
	body = "#{params[:name]} has made a new support request. #{params[:name]} can be contacted via email (#{params[:email]}) or phone (#{params[:phone]}). Their support message is: #{params[:message]}"
	Pony.mail(
		:from => 'milind@hashcooki.es',
		:to => 'milind@hashcooki.es',
		:subject => "Support Request",
		:html_body => body,
		:via => :smtp,
		:via_options => {
			  :address              => 'smtp.sendgrid.net', 
	        :port                 => '587', 
	        :user_name            => 'hashcookies', 
	        :password             => 'Nor1nderchqMudi', 
	        :authentication       => :plain
		}
	)
	redirect '/member-area'
end