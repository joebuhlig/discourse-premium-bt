DiscoursePremiumBt::Engine.routes.draw do
	get '/client_token' => 'discourse_premium#client_token'
end