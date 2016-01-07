# -*- encoding: utf-8 -*-
# stub: braintree 2.48.1 ruby lib

Gem::Specification.new do |s|
  s.name = "braintree"
  s.version = "2.48.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Braintree"]
  s.date = "2015-09-03"
  s.description = "Ruby library for integrating with the Braintree Gateway"
  s.email = "code@getbraintree.com"
  s.homepage = "http://www.braintreepayments.com/"
  s.licenses = ["MIT"]
  s.rubyforge_project = "braintree"
  s.rubygems_version = "2.4.5.1"
  s.summary = "Braintree Gateway Ruby Client Library"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 2.0.0"])
    else
      s.add_dependency(%q<builder>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 2.0.0"])
  end
end
