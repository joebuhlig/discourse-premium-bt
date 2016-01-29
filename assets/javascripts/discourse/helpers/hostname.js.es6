Ember.Handlebars.registerBoundHelper("hostname", function() {
  return Discourse.URL.origin();
});