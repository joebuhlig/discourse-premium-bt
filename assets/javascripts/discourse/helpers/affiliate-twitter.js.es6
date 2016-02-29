Ember.Handlebars.registerBoundHelper("affiliateTwitter", function() {
	var base = location.origin + '?ref=' + Discourse.User.current().id;
	var hostname = encodeURIComponent(base);
	var shareText = encodeURIComponent(I18n.t('premium_bt.affiliate_share_text', {site_name: Discourse.SiteSettings.title}));
	var twitterLink = '<a target="_blank" href="http://twitter.com/intent/tweet?url=' + hostname + '&text=' + shareText + '"><i class="fa fa-twitter-square"></i></a>'
	return twitterLink;
});