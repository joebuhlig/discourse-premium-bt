require 'braintree'

module DiscoursePremiumBt
	class DiscoursePremiumController < ::ApplicationController
		requires_plugin 'discourse-premium-bt'
		
		def client_token
	        render :text => Braintree::ClientToken.generate
		end
	end
end