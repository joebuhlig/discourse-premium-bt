[![Donate](https://img.shields.io/badge/paypal-donate-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=REDVNFMCM4KBN)

## Discourse Premium BT

**This plugin has not been tried in a production environment.** It is still in the development and testing phase.

This is a plugin for [Discourse](http://www.discourse.org/) that creates a paywall for access to a group. You can then create private categories for the group and effectively create a premium section of the community.

To use it, you'll need an account with [Braintree](https://www.braintreepayments.com). For testing purposes you can create a sandbox account. It's no fun testing with real money.

### Set up

1. Install the plugin per the [directions on meta](https://meta.discourse.org/t/install-a-plugin/19157).
2. Collect your API Keys from your Braintree account and enter them into the plugin settings in Discourse.

    <img src="/images/braintree-api-keys.png" width="500"> 

3. In Braintree, create a new Plan. This is where you set the price and billing intervals.

    <img src="/images/braintree-plan.png" width="500">

4. Add the name of the plan to the plugin settings.

    <img src="/images/premium-plan-setting.png" width="500">

5. Create a new group to put behind the paywall. You can name it whatever you like.

    <img src="/images/premium-group.png" width="500">

6. Add the group name to the plugin settings.

    <img src="/images/premium-group-setting.png" width="500">

7. It's a good idea to create a new topic on your site explaining all the details of your premium section. After you've created this topic, add the link to it in the settings. The "more info" link in the user settings will be directed to this topic.

    <img src="/images/premium-details-setting.png" width="500">

### Optional

The plugin has an affiliate portion built in. You'll need to enable it separately and add a few settings to use it.

1. Every good affiliate program rewards the user in some way this program grants a discount to the subscriber when a new user signs up for the community. You need to set up the discount in Braintree.

    <img src="/images/braintree-discount.png" width="500">

2. Enter the name of the discount in the plugin settings.

    <img src="/images/braintree-discount-setting.png" width="500">

3. Create a new topic on your site explaining the details on the affiliate program and enter the link to the topic in the settings.

    <img src="/images/affiliate-details-setting.png" width="500">
