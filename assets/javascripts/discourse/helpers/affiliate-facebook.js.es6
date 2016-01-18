Ember.Handlebars.registerBoundHelper("affiliateFacebook", function() {
	var base = document.location.host + '?ref=' + Discourse.User.current().id;
	var hostname = encodeURIComponent(base);
	var shareText = encodeURIComponent(I18n.t('premium_bt.affiliate_share_text', {site_name: Discourse.SiteSettings.title}));
	var facebookLink = '<a target="_blank" href="http://www.facebook.com/sharer.php?u=' + hostname + '&t=' + shareText + '"><i class="fa fa-facebook-square"></i></a>'
	return facebookLink;
});