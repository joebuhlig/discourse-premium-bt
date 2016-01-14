require 'braintree'

module DiscoursePremiumBt
	class DiscoursePremiumController < ::ApplicationController
		requires_plugin 'discourse-premium-bt'
		
		def client_token
	        render :text => Braintree::ClientToken.generate
		end

		def subscribe

			customer = get_customer(current_user.id, current_user.email)
			token = create_payment_token(current_user.id, params[:payment_method_nonce])
			plan_id = SiteSetting.premium_bt_plan_id

			subscription = Braintree::Subscription.create(
				:payment_method_token => token,
				:plan_id => plan_id
			)

			if subscription.success?
				current_user.custom_fields["subscription_id"] = subscription.subscription.id
				group = Group.find_by_name(SiteSetting.premium_bt_group_name)
				current_user.premium_group_grant
				title = I18n.t("premium_bt.pm_subscribe_title")
				raw = I18n.t("premium_bt.pm_subscribe_text")
				current_user.custom_fields["premium_exp_date"] = nil
				current_user.custom_fields["premium_exp_pm_sent"] = nil
				current_user.save
				current_user.send_premium_pm(title, raw)
				render json: success_json
			else
				return render_json_error(subscription.message)
			end
		end

		def change_payment
			customer = get_customer(current_user.id, current_user.email)
			token = create_payment_token(current_user.id, params[:payment_method_nonce])

			subscription = Braintree::Subscription.update(
				current_user.custom_fields["subscription_id"],
				:payment_method_token => token
			)
			if subscription.success?
				title = I18n.t("premium_bt.pm_change_payment_title")
				raw = I18n.t("premium_bt.pm_change_payment_text")
				current_user.send_premium_pm(title, raw)
	            render json: success_json
			else
				return render_json_error(subscription.message)
			end
		end

		def cancel
			subscription = Braintree::Subscription.cancel(current_user.custom_fields["subscription_id"])

			if subscription.success?
				current_user.custom_fields["subscription_id"] = nil
				current_user.premium_group_revoke
				title = I18n.t("premium_bt.pm_unsubscribe_title")
				raw = I18n.t("premium_bt.pm_unsubscribe_text")
				current_user.send_premium_pm(title, raw)
				render json: success_json
			else
				return render_json_error(subscription.message)
			end
		end

		def get_customer(id, email)
			
			begin
				customer = Braintree::Customer.find(id)
				return customer
			rescue
				customer = Braintree::Customer.create(
					:id => id,
					:email => email
				)

				if customer.success?
					return customer.customer
				else
				
				end
			end

			
		end

		def create_payment_token(id, nonce)
			payment = Braintree::PaymentMethod.create(
				:customer_id => id,
				:payment_method_nonce => nonce,
				:options => {
					:make_default => true
				}
			)
			if payment.success?
				return payment.payment_method.token
			else

			end
		end
	end
end