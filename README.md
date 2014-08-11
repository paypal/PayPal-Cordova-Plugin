# PayPal SDK Cordova/Phonegap Plugin

Disclaimer
-----------
The intention for this plugin is to make it community driven. 
We have created the initial version of the plugin to show how easy it is to use our native SDKs (iOS and Android) on the Cordova/Phonegap platforms.
As features are added to the mSDK, we will be happy to review and merge any Pull Requests that add these features to the plugin.

Installation
------------

The PayPal SDK Cordova/Phonegap Plugin adds support for the PayPal SDK on iOS and Android platforms. It uses the native PayPal Mobile SDK libraries, which you must also download. Cordova plugin management will set up all the required capabilities/frameworks for the project. The only bit left for you to do is to add necessary files, as described below.


1. Download the [PayPal iOS SDK](https://github.com/paypal/PayPal-iOS-SDK).
2. Download the [PayPal Android SDK] (https://github.com/paypal/PayPal-Android-SDK).
3. Follow the official [Cordova](https://cordova.apache.org) documentation to install command line tools and create a project.
4. Run `cordova plugin add https://github.com/paypal/PayPal-Cordova-Plugin`.
5. Run `cordova platform add ios` or/and `cordova platform add android`.
6. For iOS, open the Xcode project in the `platforms/ios` folder and add the `PayPalMobile` folder from step 1.
7. For Android, copy the `libs` folder from step 2 to the `libs` folder in `platforms/android`.
8. Run `cordova build` to build the projects for all of the platforms.


Your app integration
--------------------
The PayPal SDK Cordova/Phonegap Plugin adds 2 JavaScript files to your project.

1. `cdv-plugin-paypal-mobile-sdk.js`: a wrapper around the native SDK. The `PayPalMobile` object is immediately available to use in your `.js` files.
2. `paypal-mobile-js-helper.js`: a helper file which defines the `PayPalPayment`, `PayPalPaymentDetails` and `PayPalConfiguration` classes for use with `PayPalMobile`.

You must add `<script type="text/javascript" src="js/paypal-mobile-js-helper.js"></script>` to your `www/index.html` file, following the `cordova.js` import.


Documentation
-------------
- See `cdv-plugin-paypal-mobile-sdk.js` and `cdv-plugin-paypal-mobile-sdk.js` for more details.
- For complete documentation regarding the PayPal SDK Cordova Plugin, please refer to the documentation for the underlying [PayPal Mobile SDK](https://developer.paypal.com/webapps/developer/docs/integration/mobile/mobile-sdk-overview/).


Basic Example of the app
------------------------

In `index.html` please add the following to lines after ` <p class="event received">Device is Ready</p>`

```javascript
   <button id="buyNowBtn"> Buy Now !</button>
   <button id="buyInFutureBtn"> Pay in Future !</button>
```

Here is the full example of `www/js/index.js`


```javascript
   
/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);

        // start to initialize PayPalMobile library
        app.initPaymentUI();
    },
    initPaymentUI : function () {
      var clientIDs = {
        "PayPalEnvironmentProduction": "YOUR_PRODUCTION_CLIENT_ID",
        "PayPalEnvironmentSandbox": "YOUR_SANDBOX_CLIENT_ID"
      };
      PayPalMobile.init(clientIDs, app.onPayPalMobileInit);

    },
    onSuccesfulPayment : function(payment) {
      console.log("payment success: " + JSON.stringify(payment, null, 4));
    },
    onFuturePaymentAuthorization : function(authorization) {
      console.log("authorization: " + JSON.stringify(authorization, null, 4));
    },
    createPayment : function () {
      // for simplicity use predefined amount
      var paymentDetails = new PayPalPaymentDetails("1.50", "0.40", "0.05");
      var payment = new PayPalPayment("1.95", "USD", "Awesome Sauce", "Sale", paymentDetails);
      return payment;
    },
    configuration : function () {
      // for more options see `paypal-mobile-js-helper.js`
      var config = new PayPalConfiguration({merchantName: "My test shop", merchantPrivacyPolicyURL: "https://mytestshop.com/policy", merchantUserAgreementURL: "https://mytestshop.com/agreement"});
      return config;
    },
    onPrepareRender : function() {
      // buttons defined in index.html
      //  <button id="buyNowBtn"> Buy Now !</button>
      //  <button id="buyInFutureBtn"> Pay in Future !</button>
      var buyNowBtn = document.getElementById("buyNowBtn");
      var buyInFutureBtn = document.getElementById("buyInFutureBtn");

      buyNowBtn.onclick = function(e) {
        // single payment
        PayPalMobile.renderSinglePaymentUI(app.createPayment(), app.onSuccesfulPayment, app.onUserCanceled);
      };

      buyInFutureBtn.onclick = function(e) {
        // future payment
        PayPalMobile.renderFuturePaymentUI(app.onFuturePaymentAuthorization, app.onUserCanceled);
      };
    },
    onPayPalMobileInit : function() {
      // must be called
      // use PayPalEnvironmentNoNetwork mode to get look and feel of the flow
      PayPalMobile.prepareToRender("PayPalEnvironmentNoNetwork", app.configuration(), app.onPrepareRender);
    },
    onUserCanceled : function(result) {
      console.log(result);
    }
};


```
