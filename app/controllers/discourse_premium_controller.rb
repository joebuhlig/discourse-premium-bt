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
				if !group.users.include?(current_user)
					group.add(current_user)
				else
					return render_json_error I18n.t('groups.errors.member_already_exist', username: current_user.username)
				end

				if group.save
					title = I18n.t("premium_bt.pm_subscribe_title")
					raw = I18n.t("premium_bt.pm_subscribe_text")
					current_user.custom_fields["premium_exp_date"] = nil
					current_user.custom_fields["premium_message_sent"] = nil
					current_user.save
					PostCreator.create(
						Discourse.system_user,
						target_usernames: current_user.username,
						archetype: Archetype.private_message,
						subtype: TopicSubtype.system_message,
						title: title,
						raw: raw
		            )
					render json: success_json
				else
					return render_json_error(group)
				end
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
				PostCreator.create(
					Discourse.system_user,
					target_usernames: current_user.username,
					archetype: Archetype.private_message,
					subtype: TopicSubtype.system_message,
					title: title,
					raw: raw
	            )
	            render json: success_json
			else
				return render_json_error(subscription.message)
			end
		end

		def cancel
			subscription = Braintree::Subscription.cancel(current_user.custom_fields["subscription_id"])

			if subscription.success?
				current_user.custom_fields["subscription_id"] = nil
				group = Group.find_by_name(SiteSetting.premium_bt_group_name)
				current_user.primary_group_id = nil if current_user.primary_group_id == group.id
				group.users.delete(current_user.id)

				if group.save && current_user.save
					title = I18n.t("premium_bt.pm_unsubscribe_title")
					raw = I18n.t("premium_bt.pm_unsubscribe_text")
					PostCreator.create(
						Discourse.system_user,
						target_usernames: current_user.username,
						archetype: Archetype.private_message,
						subtype: TopicSubtype.system_message,
						title: title,
						raw: raw
		            )
					render json: success_json
				else
					return render_json_error(group)
				end
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