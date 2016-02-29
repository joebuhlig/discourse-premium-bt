Ember.Handlebars.registerBoundHelper("affiliateEmail", function() {
	var base = location.origin + '?ref=' + Discourse.User.current().id;
	var hostname = encodeURIComponent(base);
	var shareText = encodeURIComponent(I18n.t('premium_bt.affiliate_share_text', {site_name: Discourse.SiteSettings.title}));
	var emailLink = '<a target="_blank" href="mailto:?to=&subject=' + encodeURIComponent(Discourse.SiteSettings.title) + '&body=' + shareText + ' ' + hostname + '"><i class="fa fa-envelope-square"></i></a>'
	return emailLink;
});