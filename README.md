# PayPal iOS SDK Cordova Plug-in


Integration
-----------

PayPal iOS SDK Cordova Plugin adds support for PayPal SDK on iOS and Android platforms. It has a depencency on the native sdk libraries which are required to be downloaded manually. Cordova plugin management will setup all the required capabilities/frameworks to the project. The only bit left to do is to add necessary files. Here are the steps how to do it.


1. Download the [PayPal iOS SDK](https://github.com/paypal/PayPal-iOS-SDK)
2. Download the [PayPal Android SDK] (https://github.com/paypal/PayPal-Android-SDK)
3. Install [Cordova](https://cordova.apache.org) command line tools
4. Run `cordova plugin add https://github.com/paypal/PayPal-Cordova-Plugin`
5. Run `cordova platform add ios` or/and `cordova platform add android`
6. For iOS open xcode project in `platforms/ios` folder and add `PayPalMobile` folder from step 1.
7. For Android copy `libs` folder from step 2. to `libs` folder in `platforms/android`
8. Run `cordova build` to build all the platforms


Your app integration
--------------------
Plugin adds 2 javascript files to your project.

1. `cdv-plugin-paypal-mobile-sdk.js` wrapper around native sdk. PayPalMobile oject is immidiately available to use in your `.js` files.
2. `paypal-mobile-js-helper.js` helper file defines _PayPalPayment_, _PayPalPaymentDetails_ and _PayPalConfiguration_ objects to help working with _PayPalMobile_

You have to add `<script type="text/javascript" src="js/paypal-mobile-js-helper.js"></script>` in your `www/index.html` file after `cordova.js` import to be able to use it.


Taking a Single Payment example
-------------------------------

```javascript
   
var payment = new PayPalPayment("1.95", "USD", "awesome souce", "Sale", null);

var onSuccessPayment = function(payment) {
   console.log("payment successful: " + JSON.stringify(payment, null, 4));
 // send payment object to your server for verification
};


var prepareToRenderCallback = function(result) {
  PayPalMobile.renderSinglePaymentUI(payment, onSuccessPayment, function (result) {
  // user cancelled
  console.log(result);
  });
};

var initComplete = function() {
  // set envrionment you want to use along with configuration
  PayPalMobile.prepareToRender("PayPalEnvironmentNoNetwork", new PayPalConfiguration(), prepareToRenderCallback);
};

var clientIDs = {
  "PayPalEnvironmentProduction": "YOUR_PRODUCTION_CLIENT_ID",
  "PayPalEnvironmentSandbox": "YOUR_SANDOX_CLIENT_ID"
};

PayPalMobile.init(clientIDs, initComplete);

```

Getting Future Payment authorization example
--------------------------------------------
```json
var onSuccessfulAuthorization = function(result) {
   console.log("auth successful: " + JSON.stringify(result, null, 4));
   // send result object to your server for next steps
};


var prepareToRenderCallback = function(result) {
  PayPalMobile.renderFuturePaymentUI(onSuccessfulAuthorization, function (result) {
  // user cancelled
  console.log(result);
  });
};

var initComplete = function() {
  // set envrionment you want to use along with configuration
  var config = new PayPalConfiguration({merchantName: "My Awesome Merchant", merchantPrivacyPolicyURL: "https://mymerchant.com/policy.html", merchantUserAgreementURL: "https://mymerchant.com/useragreement.html"});
  PayPalMobile.prepareToRender("PayPalEnvironmentNoNetwork", config, prepareToRenderCallback);
};

var clientIDs = {
  "PayPalEnvironmentProduction": "YOUR_PRODUCTION_CLIENT_ID",
  "PayPalEnvironmentSandbox": "YOUR_SANDOX_CLIENT_ID"
};

PayPalMobile.init(clientIDs, initComplete);

```
