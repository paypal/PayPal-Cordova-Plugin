# PayPal SDK Cordova/Phonegap Plugin


Disclaimer
-----------
The intention for this plugin is to make it community driven.
We have created the initial version of the plugin to show how easy it is to use our native SDKs (iOS and Android) on the Cordova/Phonegap platforms.
As features are added to the mSDK, we will be happy to review and merge any Pull Requests that add these features to the plugin.


Updating from earlier versions < 3.0.0
-----------------------------
Please remove your local copies of the native sdks, the Plugin now includes sdks distributions as part of the source code to make integration and version parity easier to maintain.


Installation
------------

The PayPal SDK Cordova/Phonegap Plugin adds support for the PayPal SDK on iOS and Android platforms. It uses the native PayPal Mobile SDK libraries, which you must also download. Cordova plugin management will set up all the required capabilities/frameworks for the project. The only bit left for you to do is to add necessary files, as described below.


1. Follow the official [Cordova](https://cordova.apache.org) documentation to install command line tools or [Phonegap](http://phonegap.com/install/).
2. Create project, add plugin and platforms:
```bash
   $ cordova create MyShop com.mycompany.myshop "MyShop"
   $ cd MyShop
   # using cordova repository (many thanks to @Ramneekhanda for helping with this)
   $ cordova plugin add com.paypal.cordova.mobilesdk
   # or you can also install directly from github
   #$ cordova plugin add https://github.com/paypal/PayPal-Cordova-Plugin
   $ cordova platform add ios
   $ cordova platform add android
   # optional for console.log etc
   $ cordova plugin add org.apache.cordova.console
```
3. Follow Your app integration section below.
4. Run `cordova build` to build the projects for all of the platforms.


Phonegap Build
--------------
If you using phonegap build just add `<gap:plugin name="com.paypal.cordova.mobilesdk" source="npm" />` to your config.xml. To specify a particular version use `<gap:plugin name="com.paypal.cordova.mobilesdk" version="3.1.8" />`.
For more details check http://docs.build.phonegap.com/en_US/configuring_plugins.md.html#Plugins

Your app integration
--------------------
The PayPal SDK Cordova/Phonegap Plugin adds 2 JavaScript files to your project.

1. `cdv-plugin-paypal-mobile-sdk.js`: a wrapper around the native SDK. The `PayPalMobile` object is immediately available to use in your `.js` files. You DON'T need to reference it in index.html.
2. `paypal-mobile-js-helper.js`: a helper file which defines the `PayPalPayment`, `PayPalPaymentDetails` and `PayPalConfiguration` classes for use with `PayPalMobile`.
3. You must add
```javascript
   <script type="text/javascript" src="js/paypal-mobile-js-helper.js"></script>
```
   to your `MyShop/www/index.html` file, _after_ the `cordova.js` import.


Documentation
-------------
- All calls to PayPalMobile are asynchronous.
- See `cdv-plugin-paypal-mobile-sdk.js` and `paypal-mobile-js-helper.js` for details and functionality available.
- For complete documentation regarding the PayPal SDK Cordova Plugin, please refer to the documentation for the underlying [PayPal Mobile SDK](https://developer.paypal.com/webapps/developer/docs/integration/mobile/mobile-sdk-overview/).
- Not all features available in native sdks have been implemented.

Using card.io scanning abilities independently
----------------------------------------------

PayPal SDK Cordova Plugin now allows you to directly invoke card.io scanning abilities as provided by [card.io Cordova Plugin](https://github.com/card-io/card.io-Cordova-Plugin). The implementation is shown below in the samples.


Basic Example of the app
------------------------

1. A complete example code can be checked from here https://github.com/romk1n/MyCordovaShop

1. In `MyShop/www/index.html` add the following to lines after `<p class="event received">Device is Ready</p>`:
   ```javascript
      <button id="buyNowBtn"> Buy Now !</button>
      <button id="buyInFutureBtn"> Pay in Future !</button>
      <button id="profileSharingBtn"> Profile Sharing !</button>
      <button id="cardScanBtn">Advanced: Use card.io scan only</button>
   ```

2. Replace `MyShop/www/js/index.js` with the following code:
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
       // This code is only used for independent card.io scanning abilities
       onCardIOComplete: function(card) {
         console.log("Card Scanned success: " + JSON.stringify(card, null, 4));
       },
       onAuthorizationCallback : function(authorization) {
         console.log("authorization: " + JSON.stringify(authorization, null, 4));
       },
       createPayment : function () {
         // for simplicity use predefined amount
         // optional payment details for more information check [helper js file](https://github.com/paypal/PayPal-Cordova-Plugin/blob/master/www/paypal-mobile-js-helper.js)
         var paymentDetails = new PayPalPaymentDetails("50.00", "0.00", "0.00");
         var payment = new PayPalPayment("50.00", "USD", "Awesome Sauce", "Sale", paymentDetails);
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
         //  <button id="profileSharingBtn"> ProfileSharing !</button>
         //  <button id="cardScanBtn">Advanced: Use card.io scan only</button>
         var buyNowBtn = document.getElementById("buyNowBtn");
         var buyInFutureBtn = document.getElementById("buyInFutureBtn");
         var profileSharingBtn = document.getElementById("profileSharingBtn");
         var cardScanBtn = document.getElementById("cardScanBtn");

         buyNowBtn.onclick = function(e) {
           // single payment
           PayPalMobile.renderSinglePaymentUI(app.createPayment(), app.onSuccesfulPayment, app.onUserCanceled);
         };

         buyInFutureBtn.onclick = function(e) {
           // future payment
           PayPalMobile.renderFuturePaymentUI(app.onAuthorizationCallback, app.onUserCanceled);
         };

         profileSharingBtn.onclick = function(e) {
           // profile sharing
           PayPalMobile.renderProfileSharingUI(["profile", "email", "phone", "address", "futurepayments", "paypalattributes"], app.onAuthorizationCallback, app.onUserCanceled);
         };
         
         cardScanBtn.onclick = function(e) {
           // card.io scanning independent of paypal payments. 
           // This is used for cases where you only need to scan credit cards and not use PayPal as funding option.
           CardIO.scan({
                        "requireExpiry": true,
                        "requireCVV": false,
                        "requirePostalCode": false,
                        "restrictPostalCodeToNumericOnly": true
                      },
                      app.onCardIOComplete,
                      app.onUserCanceled
                    );
          };
       },
       onPayPalMobileInit : function() {
         // must be called
         // use PayPalEnvironmentNoNetwork mode to get look and feel of the flow
         PayPalMobile.prepareToRender("PayPalEnvironmentSandbox", app.configuration(), app.onPrepareRender);
       },
       onUserCanceled : function(result) {
         console.log(result);
       }
   };

   app.initialize();
   ```
3. execute `cordova run ios` or `cordova run android` to install and run your sample code.

## License
Code released under [BSD LICENSE](LICENSE)

## Contributions 
 Pull requests and new issues are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.
