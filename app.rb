$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sass'
require 'lib/authorization'
require 'carrierwave'
require 'carrierwave/datamapper'
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

DataMapper::Property::String.length(255)
DataMapper::Model.raise_on_save_failure = true 

helpers do
	include Sinatra::Authorization
end

class Hotel
	include DataMapper::Resource
	property :id,			Serial
	property :name,			String
	property :slug,			String
	property :desc,			Text
	property :short_desc,	String			# For thumbnail description
	property :city,			String
	property :state,		String
	property :country,		String
	property :price,		Integer
	property :thumbnail,	String
	property :created_at,	DateTime
	property :updated_at,	DateTime
end

DataMapper.auto_upgrade!

get '/first-run' do
	require_admin

	cc = Country.create(:name => 'India', :short_name => 'IN')
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
	@page_title += " | Members Area (Private)"
	@body_class += " members-area"
	erb :member_area
end

get '/hotels/new' do
	require_admin

	@page_title += " | New Hotel"
	@body_class += " new-hotel"
	erb :new_hotel
end

get '/admin' do	
	require_admin
	
	@page_title += " | Palmarinha Admin"
	@body_class += " admin"
	@hotels = Hotel.all
	erb :admin
end

post '/request-membership' do
	require 'pony'
	#Pony.options = { :from => params[:member][:name] }
	Pony.mail(
		:from => params[:member][:name],
		:to => 'alistair.rodrigues@gmail.com',
		:subject => "Membership Request",
		:html_body => params[:member][:name] << " wishes to be a member <br /> Contact by phone: " << params[:member][:phone] << " by email: " << params[:member][:eadd],
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

load 'actions/route_state.rb'