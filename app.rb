$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sass'
require 'lib/authorization'
require 'carrierwave'
require 'carrierwave/datamapper'
enable :sessions

get '/css/main.css' do
	content_type 'text/css', :charset => 'utf-8'
	scss(:"css/main")
end


helpers do
	include Sinatra::Authorization
	
	# def partial template
	# 	erb template, :layout => false
	# end
end

before do
	@page_title = "Palmarinha Holidays"
	@body_class = ""
end

after do
	#session[:status] = "fresh"
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
	erb :member_area
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

