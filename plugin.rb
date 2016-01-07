# name: Discourse Premium BT
# about: Adds a membership section to Discourse
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/joebuhlig/discourse-premium-bt

register_asset "stylesheets/premium_bt.scss"
register_asset "javascripts/braintree.js"

enabled_site_setting :premium_bt_enabled

gem 'braintree', '2.48.1'

# load the engine
load File.expand_path('../lib/discourse_premium_bt/engine.rb', __FILE__)

after_initialize do

	Braintree::Configuration.environment = eval(SiteSetting.premium_bt_environment)
	Braintree::Configuration.merchant_id = SiteSetting.premium_bt_merchant_id
	Braintree::Configuration.public_key = SiteSetting.premium_bt_public_key
	Braintree::Configuration.private_key = SiteSetting.premium_bt_private_key

	CurrentUserSerializer.class_eval do

	    attributes :premium

	    def premium
	    	groups = []
			user_groups = GroupUser.where(user_id: object.id)
			user_groups.each_with_index do |user_group, i|
				group = Group.where(id: user_group.group_id).first
				if group.name == SiteSetting.premium_bt_group_name
					return true
				end
			end
			return false
	    end

	end

	Discourse::Application.routes.append do
		mount ::DiscoursePremiumBt::Engine, at: "/premium"
	end
end