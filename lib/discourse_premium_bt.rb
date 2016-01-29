module DiscoursePremiumBt
	def self.validate
		if SiteSetting.premium_bt_enabled
			Braintree::Configuration.environment = eval(SiteSetting.premium_bt_environment)
			Braintree::Configuration.merchant_id = SiteSetting.premium_bt_merchant_id
			Braintree::Configuration.public_key = SiteSetting.premium_bt_public_key
			Braintree::Configuration.private_key = SiteSetting.premium_bt_private_key
		end
	end
end