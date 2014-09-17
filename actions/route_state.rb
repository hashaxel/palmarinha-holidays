# get '/state/new' do
# 	require_admin
	
# 	@countries = Country.all
# 	erb :new_state
# end

# post '/state/create' do
# 	# state  = State.create(params[:state])
# 	country = Country.get(params[:country][:id])
# 	state = State.new(params[:state])
# 	country.states << state
	
# 	if state.save
# 		redirect '/'
# 	else
# 		redirect '/state/new'
# 	end
# end

# get '/state/:id' do
# 	@state = Sate.get(params[:id])
# 	erb :state
# end