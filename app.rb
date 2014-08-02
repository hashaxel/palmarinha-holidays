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
	@body_class += " members"
	@bg_img = "member-banner"
	@controls = :_member_controls
	erb :membership
end


# post '/send-inquiry' do
# 	require 'pony'
# 	Pony.mail(
# 		:from => params[:inquiry][:name],
# 		:to => 'milind@hashcooki.es',
# 		:subject => "New Inquiry for" + params[:inquiry][:books],
# 		:body => params[:inquiry][:books],
# 		:via => :smtp,
# 		:via_options => {
# 			:address              => 'smtp.sendgrid.net', 
# 	        :port                 => '587', 
# 	        :user_name            => 'hashcookies', 
# 	        :password             => 'Nor1nderchqMudi', 
# 	        :authentication       => :plain
# 		}
# 	)
# 	redirect '/'
# end

