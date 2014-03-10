# PayPal SDK Cordova Plug-in


Integration
-----------

The PayPal SDK Cordova Plugin adds support for the PayPal SDK on iOS and Android platforms. It has a depencency on the native SDK libraries, which you must also download. Cordova plugin management will set up all the required capabilities/frameworks for the project. The only bit left for you to do is to add necessary files, as described below.


1. Download the [PayPal iOS SDK](https://github.com/paypal/PayPal-iOS-SDK).
2. Download the [PayPal Android SDK] (https://github.com/paypal/PayPal-Android-SDK).
3. Install the [Cordova](https://cordova.apache.org) command line tools.
4. Run `cordova plugin add https://github.com/paypal/PayPal-Cordova-Plugin`.
5. Run `cordova platform add ios` or/and `cordova platform add android`.
6. For iOS, open the Xcode project in the `platforms/ios` folder and add the `PayPalMobile` folder from step 1.
7. For Android, copy the `libs` folder from step 2 to the `libs` folder in `platforms/android`.
8. Run `cordova build` to build the projects for all of the platforms.


Your app integration
--------------------
The PayPal SDK Cordova Plugin adds 2 JavaScript files to your project.

1. `cdv-plugin-paypal-mobile-sdk.js`: a wrapper around the native SDK. The `PayPalMobile` object is immediately available to use in your `.js` files.
2. `paypal-mobile-js-helper.js`: a helper file which defines the `PayPalPayment`, `PayPalPaymentDetails` and `PayPalConfiguration` classes for use with `PayPalMobile`.

You must add `<script type="text/javascript" src="js/paypal-mobile-js-helper.js"></script>` to your `www/index.html` file, following the `cordova.js` import.


Single Payment example
----------------------

```javascript
   
var payment = new PayPalPayment("1.95", "USD", "awesome souce", "Sale", null);

var onSuccessPayment = function(payment) {
   console.log("payment successful: " + JSON.stringify(payment, null, 4));
 // send payment object to your server for verification
};


var prepareToRenderCallback = function(result) {
  PayPalMobile.renderSinglePaymentUI(payment, onSuccessPayment, function (result) {
  // user canceled
  console.log(result);
  });
};

var initComplete = function() {
  // set envrionment and configuration
  PayPalMobile.prepareToRender("PayPalEnvironmentNoNetwork", new PayPalConfiguration(), prepareToRenderCallback);
};

var clientIDs = {
  "PayPalEnvironmentProduction": "YOUR_PRODUCTION_CLIENT_ID",
  "PayPalEnvironmentSandbox": "YOUR_SANDOX_CLIENT_ID"
};

PayPalMobile.init(clientIDs, initComplete);

```

Future Payment authorization example
------------------------------------
```json
var onSuccessfulAuthorization = function(result) {
   console.log("auth successful: " + JSON.stringify(result, null, 4));
   // send result object to your server for next steps
};


var prepareToRenderCallback = function(result) {
  PayPalMobile.renderFuturePaymentUI(onSuccessfulAuthorization, function (result) {
  // user canceled
  console.log(result);
  });
};

var initComplete = function() {
  // set envrionment and configuration
  var config = new PayPalConfiguration({merchantName: "My Awesome Merchant", merchantPrivacyPolicyURL: "https://mymerchant.com/policy.html", merchantUserAgreementURL: "https://mymerchant.com/useragreement.html"});
  PayPalMobile.prepareToRender("PayPalEnvironmentNoNetwork", config, prepareToRenderCallback);
};

var clientIDs = {
  "PayPalEnvironmentProduction": "YOUR_PRODUCTION_CLIENT_ID",
  "PayPalEnvironmentSandbox": "YOUR_SANDOX_CLIENT_ID"
};

PayPalMobile.init(clientIDs, initComplete);

```
