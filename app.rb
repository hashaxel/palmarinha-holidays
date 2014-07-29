$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'data_mapper'
require 'mysql'
require 'sass'
require 'lib/authorization'
require 'carrierwave'
require 'carrierwave/datamapper'
enable :sessions

get '/css/main.css' do
	content_type 'text/css', :charset => 'utf-8'
	scss(:"css/main")
end

configure :development do
	require 'dm-sqlite-adapter'
	DataMapper::Logger.new($stdout, :debug)
	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/palmarinha.db")
end

# configure :production do
# 	require 'dm-mysql-adapter'
# 	DataMapper.setup(:default, 'mysql://root:hash2014@127.0.0.1/oib')
# end

class Book
	include DataMapper::Resource
	
	property :id,				Serial
	property :title,			String, :required => true
	property :slug,				String
	property :description,		Text
	property :shortdesc,		Text
	property :price_usd,		Integer
	property :price_inr,		Integer
	property :type,				Text
	property :printed_pages,	Integer
	property :category_id,		Integer
	property :author_id,		Integer
	property :publisher_id,		Integer
	property :is_active,		Boolean, :default => true
	property :is_featured,		Boolean
	property :cover_url,		String
	property :thumbnail_url,	String
	property :release_month,	Integer
	property :release_year,		Integer
	property :created_at,		DateTime
	property :updated_at,		DateTime
	
	has n, :images
	belongs_to :category
	belongs_to :author
	belongs_to :publisher
	
	def handle_upload(file)
		path = File.join(Dir.pwd, "/public/books/images", file[:filename].downcase.gsub(" ", "-"))
		File.open(path, "wb") do |f|
			f.write(file[:tempfile].read)
		end	
		
	end
end

class Author
	include DataMapper::Resource

	property :id,			Serial
	property :name,			String
	property :description,	Text

	has n, :books
end

class Publisher
	include DataMapper::Resource

	property :id,			Serial
	property :name,			String

	has n, :books
end

class Image
	include DataMapper::Resource
	
	property :id,			Serial
	property :book_id,		Integer
	property :url, 			String
	
	belongs_to :book
end

class Category
	include DataMapper::Resource
	
	property :id, 			Serial
	property :name,			String
	property :description,	Text
	#property :image,		String
	
	has n, :books
end

helpers do
	include Sinatra::Authorization
	
	def partial template
		erb template, :layout => false
	end
end

before do
	@page_title = "Palmarinha Holidays"
	session[:status] ||= "fresh"
	session[:books] ||= {}
	@body_class = "default #{session[:status]}"
end

after do
	session[:status] = "fresh"
end

get '/reset' do
	DataMapper.finalize

	DataMapper.auto_upgrade!

	auth = Author.first_or_create(:name => "Author", :description => "Author Description")
	cate = Category.first_or_create(:name => "Category", :description => "Category Description")
	publ = Publisher.first_or_create(:name => "Other India Press")
end

get '/' do
	@page_title = "#{@page_title} | Home"
	@books = Book.all(:is_featured => true, :category_id => 1, :limit => 6)
	@date_books = Book.all(:is_featured => true, :release_year => 2010, :limit => 6)
	@publisher_books = Book.all(:is_featured => true, :publisher_id => 1, :limit => 6)
	@category = Category.get (1)
	@category.description = @category.description.gsub(/^(.*)$/, '<p>\1</p>')
	erb :home
end

get '/books/?' do
	@page_title = "#{@page_title} | Books"
	@books = Book.all
	@category = Category.get(1)
	@category.description = @category.description.gsub(/^(.*)$/, '<p>\1</p>')
	erb :books
end

get '/books/new' do
	require_admin
	@page_title = "New Book"
	@authorised = true
	erb :new
	
end

post '/create' do
	require_admin
	
	category = Category.get(params[:book][:category_id])
	author = Author.get(params[:book][:author_id])
	publisher = Publisher.get(params[:book][:publisher_id])
	
	@book = Book.new(params[:book])
	
	category.books << @book
	author.books << @book
	publisher.books << @book
	
	@book.slug = @book.title.downcase.gsub(" ", "-")
	@book.cover_url = params[:cover_url][:filename].downcase.gsub(" ", "-")
	
	if @book.save
		@book.handle_upload(params[:cover_url]) unless params[:cover_url].nil?
		redirect "/book/#{@book.id}/#{@book.slug}"
	else
		redirect "/"
	end
end

post '/create-new/:newtype' do
	require_admin

	@create_type = params[:newtype]
	#@new_value = params[:new]
	@save_val = ""
	case @create_type
	when "category"
		@save_val = Category.new(params[:category])
	when "author"
		@save_val = Author.new(params[:author])
	when "publisher"
		@save_val = Publisher.new(params[:publisher])
	else
		raise "Book"
	end

	if @save_val.save
		redirect "/admin"
	else
		redirect "/admin"
	end
end

post '/update' do
	require_admin
	@book = Book.get(params[:book][:id])
	@update_params = params[:book]
	@cover_url = params[:book][:cover_url]
	
	@update_params[:cover_url] = params[:book][:cover_url][:filename] unless params[:book][:cover_url].nil?
	@update_params[:is_featured] = params[:book][:is_featured] == 'on' ? true : false	
	
	#raise params[:book][:cover_url].downcase.gsub(" ", "-")

	unless @cover_url.nil?
		@update_params[:cover_url] = params[:book][:cover_url].downcase.gsub(" ", "-")
		@book.handle_upload(@cover_url)
	end

	if @book.update(@update_params)
		redirect "/admin"
	else
		redirect "/book/#{@book.id}/edit"
	end
end

get '/book/:id/edit' do
	require_admin
	@authorised = true
	@book = Book.get(params[:id])
	#@images = @book.images
	erb :editbook
end

get '/book/:id/:slug/?' do
	@book = Book.get(params[:id])
	@publisher =Publisher.get(@book.publisher_id)
	#@pub_name = @publisher.name
	@author = Author.get(@book.author_id)
	#@author_name = @author.name
	@category = Category.get(@book.category_id)
	@category.description = @category.description.gsub(/^(.*)$/, '<p>\1</p>')
	#@images = @book.images
	@books_desc = @book.description.gsub(/^(.*)$/, '<p>\1</p>')
	@books = Book.all(:is_featured => true, :category_id => @book.category_id, :limit => 6)
	@author_books = Book.all(:is_featured => true, :author_id => @book.author_id, :limit => 6) # for the books from this author section
	@page_title = "#{@page_title} | #{@book.title}"
	session[:books][@book.id] =  @book.title
	@session = session[:books]
	
	if @book
		erb :show
	else
		redirect('/')
	end
end

delete 'book/destroy/:id' do
	require_admin
	@book = Book.get(params[:id])
	
	if @book.destroy!
		redirect '/admin'
	else
		redirect '/'
	end
end

post '/send-inquiry' do
	require 'pony'
	Pony.mail(
		:from => params[:inquiry][:name],
		:to => 'milind@hashcooki.es',
		:subject => "New Inquiry for" + params[:inquiry][:books],
		:body => params[:inquiry][:books],
		:via => :smtp,
		:via_options => {
			:address              => 'smtp.sendgrid.net', 
	        :port                 => '587', 
	        :user_name            => 'hashcookies', 
	        :password             => 'Nor1nderchqMudi', 
	        :authentication       => :plain
		}
	)
	redirect '/'
end

get '/admin/?' do
	require_admin
	@authorised = true
	@books = Book.all
	@authors = Author.all
	@publishers = Publisher.all
	@categories = Category.all
	erb :admin
end

get '/cap/new' do
	require_admin
	@authorised = true
	@page_title = "New |C|ategory |A|uthor |P|ublisher"
	erb :newcap
end

#load 'actions/route_authors.rb'
#load 'actions/route_publishers.rb'
#load 'actions/route_categories.rb'