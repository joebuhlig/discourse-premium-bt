# name: Discourse Premium BT
# about: Adds a membership section to Discourse
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/joebuhlig/discourse-premium-bt

register_asset "stylesheets/premium_bt.scss"
register_asset "javascripts/premium_bt.js"
register_asset "javascripts/braintree.js"

enabled_site_setting :premium_bt_enabled

gem 'braintree', '2.48.1'

# load the engine
load File.expand_path('../lib/discourse_premium_bt/engine.rb', __FILE__)

after_initialize do

	if SiteSetting.premium_bt_enabled
		load File.expand_path("../app/jobs/expiration_warning.rb", __FILE__)
		load File.expand_path("../app/jobs/free_month_expiration.rb", __FILE__)
		load File.expand_path("../app/jobs/validate_subscriptions.rb", __FILE__)

		Braintree::Configuration.environment = eval(SiteSetting.premium_bt_environment)
		Braintree::Configuration.merchant_id = SiteSetting.premium_bt_merchant_id
		Braintree::Configuration.public_key = SiteSetting.premium_bt_public_key
		Braintree::Configuration.private_key = SiteSetting.premium_bt_private_key
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

		def grant_free_month
			# If affiliate program is in use
			if SiteSetting.premium_bt_affiliate
				# If they have a current subscription
				if !self.custom_fields['subscription_id'].nil?
					subscription = Braintree::Subscription.find(self.custom_fields["subscription_id"])
					discounts = subscription.discounts
					number_of_billing_cycles = 1

					if discounts.empty?
						subscription = Braintree::Subscription.update(
							self.custom_fields["subscription_id"],
							:discounts => {
								:add => [
									{
									:inherited_from_id => SiteSetting.premium_bt_plan_discount
									}
								]
							}
						)
					else
						discounts.each do |discount|
							if discount.id == SiteSetting.premium_bt_plan_discount
								number_of_billing_cycles = discount.number_of_billing_cycles + 1
							end
						end

						subscription = Braintree::Subscription.update(
							self.custom_fields["subscription_id"],
							:discounts => {
								:update => [
									{
									:existing_id => SiteSetting.premium_bt_plan_discount,
									:number_of_billing_cycles => number_of_billing_cycles
									}
								]
							}
						)
					end
					if subscription.success?
						title = I18n.t("premium_bt_messages.pm_free_month_title")
						raw = I18n.t("premium_bt_messages.pm_free_month_text")
						send_premium_pm(title, raw)
					end
				# If no current subscription exists
				else
					if !(premium_for_life)
						if self.custom_fields["premium_exp_date"].nil?
							expiration = Time.now + 1.month
						else
							expiration = self.custom_fields["premium_exp_date"] + 1.month
						end

						premium_group_grant
						self.custom_fields["premium_exp_date"] = expiration
						self.custom_fields["premium_exp_pm_sent"] = false
						self.save
						title = I18n.t("premium_bt_messages.pm_free_month_title")
						raw = I18n.t("premium_bt_messages.pm_free_month_text")
						send_premium_pm(title, raw)
					end
				end
			end
		end

		def premium_group_grant
			group = Group.find_by_name(SiteSetting.premium_bt_group_name)
			if !group.users.include?(self)
				group.add(self)
			end
			group.save
		end

		def premium_group_revoke
			group = Group.find_by_name(SiteSetting.premium_bt_group_name)
			self.primary_group_id = nil if self.primary_group_id == group.id
			group.users.delete(self.id)
			group.save
			self.save
		end

		def premium_group_check
			groups = self.groups
			groups.each do |group|
				group = Group.where(id: group.id).first
				if group.name == SiteSetting.premium_bt_group_name
					return true
				end
			end
			return false
		end

		def premium_subscriber
			if !self.custom_fields['subscription_id'].nil?
				return true
			else
				return false
			end
		end

		def premium_for_life
			if premium_group_check and !premium_subscriber and self.custom_fields["premium_exp_date"].nil?
				return true
			else
				return false
			end
		end

		def send_premium_pm(title, raw)
			PostCreator.create(
				Discourse.system_user,
				target_usernames: self.username,
				archetype: Archetype.private_message,
				subtype: TopicSubtype.system_message,
				title: title,
				raw: raw
            )
		end
	end

	require_dependency 'users_controller'
	class ::UsersController
		after_filter :referral_check, only: [:perform_account_activation]

		def referral_check
			if SiteSetting.premium_bt_affiliate and cookies[:discourse_prem_aff] and !User.find_by_id(cookies[:discourse_prem_aff]).nil?
				user = User.find_by_id(cookies[:discourse_prem_aff])
				user.grant_free_month
			end
		end
	end

	require_dependency 'current_user_serializer'
	class ::CurrentUserSerializer

	    attributes :premium, :subscriber

	    def premium
	    	premium = object.premium_group_check
	    end

	    def subscriber
	    	subscriber = object.premium_subscriber
	    end

	end

	Discourse::Application.routes.append do
		mount ::DiscoursePremiumBt::Engine, at: "/premium"
	end
end