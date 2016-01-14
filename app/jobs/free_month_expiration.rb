module DiscoursePremiumBt
	class FreeMonthExpiration < ::Jobs::Scheduled
		every 1.hour

		def execute(args)
			group = Group.find_by_name(SiteSetting.premium_bt_group_name)
			group.users.each do |user|
				if user.custom_fields['premium_exp_date'] < Time.now + 40.days
					user.premium_group_revoke
					title = I18n.t("premium_bt.pm_expired_title")
					raw = I18n.t("premium_bt.pm_expired_text")
					user.send_premium_pm(title, raw)
					user.custom_fields['premium_exp_pm_sent'] = true
					user.save
				end
			end
		end
	end
end