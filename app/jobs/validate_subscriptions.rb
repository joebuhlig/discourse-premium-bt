module DiscoursePremiumBt
	class ValidateSubscriptions < ::Jobs::Scheduled
		every 1.minute

		def execute(args)
			users = User.all
			users.each do |user|
				# If they are a paying customer
				if user.subscriber
					subscription = Braintree::Subscription.find(user.custom_fields["subscription_id"])
		byebug
					status = subscription.status
					if status = Braintree::Subscription::Status::Active
						user.custom_fields["premium_exp_pm_sent"] = nil
						user.custom_fields["premium_exp_date"] = nil
						user.save
					elsif status = Braintree::Subscription::Status::Canceled
						user.premium_group_revoke
						user.custom_fields["subscription_id"] = nil
						user.custom_fields["premium_exp_pm_sent"] = nil
						user.custom_fields["premium_exp_date"] = nil
						title = I18n.t("premium_bt_messages.pm_canceled_title")
						raw = I18n.t("premium_bt_messages.pm_canceled_text")
						user.send_premium_pm(title, raw)
						user.save
					elsif status = Braintree::Subscription::Status::Expired
						user.premium_group_revoke
						Braintree::Subscription.cancel(user.custom_fields["subscription_id"])
						user.custom_fields["subscription_id"] = nil
						user.custom_fields["premium_exp_pm_sent"] = nil
						user.custom_fields["premium_exp_date"] = nil
						title = I18n.t("premium_bt_messages.pm_expired_title")
						raw = I18n.t("premium_bt_messages.pm_expired_text")
						user.send_premium_pm(title, raw)
						user.save
					elsif status = Braintree::Subscription::Status::PastDue
						user.premium_group_revoke
						Braintree::Subscription.cancel(user.custom_fields["subscription_id"])
						user.custom_fields["subscription_id"] = nil
						user.custom_fields["premium_exp_pm_sent"] = nil
						user.custom_fields["premium_exp_date"] = nil
						title = I18n.t("premium_bt_messages.pm_overdue_title")
						raw = I18n.t("premium_bt_messages.pm_overdue_text")
						user.send_premium_pm(title, raw)
						user.save
					elsif status = Braintree::Subscription::Status::Pending
						user.custom_fields["premium_exp_pm_sent"] = nil
						user.custom_fields["premium_exp_date"] = nil
						user.save
					end	
				end

				# If they were given free access for life
				if user.premium_for_life
					user.custom_fields["premium_exp_pm_sent"] = nil
					user.custom_fields["subscription_id"] = nil
				end

				# If they are in a free month with an expiration
				if user.premium and !user.subscriber and !user.custom_fields["premium_exp_date"].nil?
				end
			end
		end
	end
end