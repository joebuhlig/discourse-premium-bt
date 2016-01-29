module DiscoursePremiumBt
	class ExpirationWarning < ::Jobs::Scheduled
		every 1.hour

		def execute(args)
			group = Group.find_by_name(SiteSetting.premium_bt_group_name)
			group.users.each do |user|
				if !user.custom_fields['premium_exp_date'].nil? and (user.custom_fields['premium_exp_date']<(Time.now + 3.days)) and (user.custom_fields['premium_exp_pm_sent'] == false)
					title = I18n.t("premium_bt_messages.pm_warning_title")
					raw = I18n.t("premium_bt_messages.pm_warning_text")
					user.send_premium_pm(title, raw)
					user.custom_fields['premium_exp_pm_sent'] = true
					user.save
				end
			end
		end
	end
end