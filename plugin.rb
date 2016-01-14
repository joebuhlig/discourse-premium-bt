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

	require_dependency 'current_user_serializer'
	class ::CurrentUserSerializer

	    attributes :premium

	    def premium
	    	groups = object.groups
			groups.each do |group|
				group = Group.where(id: group.id).first
				if group.name == SiteSetting.premium_bt_group_name
					return true
				end
			end
			return false
	    end

	end

	require_dependency "application_controller"
	class ::ApplicationController
		before_filter :ref_to_cookie

		def ref_to_cookie
			if SiteSetting.premium_bt_affiliate and params[:ref] and !User.find_by_id(params[:ref]).nil?
				cookies[:discourse_prem_aff] = { :value => params[:ref], :expires => 30.days.from_now }
			end
		end
	end

	require_dependency 'user'
	class ::User
		after_create :check_for_refferal

		def check_for_refferal
			if SiteSetting.premium_bt_affiliate and cookies[:discourse_prem_aff] and !User.find_by_id(cookies[:discourse_prem_aff]).nil?
				grant_free_month(cookies[:discourse_prem_aff])
			end
		end

		def grant_free_month(id)

		end
	end

	Discourse::Application.routes.append do
		mount ::DiscoursePremiumBt::Engine, at: "/premium"
	end
end