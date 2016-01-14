module DiscoursePremiumBt
	class ExpirationWarning < ::Jobs::Scheduled
		every 1.minute

		def execute(args)

		end
	end
end