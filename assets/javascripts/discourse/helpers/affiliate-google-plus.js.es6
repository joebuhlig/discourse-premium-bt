Ember.Handlebars.registerBoundHelper("affiliateGooglePlus", function() {
	var base = location.origin + '?ref=' + Discourse.User.current().id;
	var hostname = encodeURIComponent(base);
	var shareText = encodeURIComponent(I18n.t('premium_bt.affiliate_share_text', {site_name: Discourse.SiteSettings.title}));
	var googlePlusLink = '<a target="_blank" href="https://plus.google.com/share?url=' + hostname + '"><i class="fa fa-google-plus-square"></i></a>'
	return googlePlusLink;
});