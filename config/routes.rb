DiscoursePremiumBt::Engine.routes.draw do
	get '/client_token' => 'discourse_premium#client_token'
	post '/subscribe' => 'discourse_premium#subscribe'
	post '/change_payment' => 'discourse_premium#change_payment'
	post '/cancel' => 'discourse_premium#cancel'
end