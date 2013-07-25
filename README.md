# PayPal iOS SDK PhoneGap Plug-in


Integration
-----------
0. Download the [PayPal iOS SDK](https://github.com/paypal/PayPal-iOS-SDK)
1. Read the [iOS Integration Guide](https://developer.paypal.com/webapps/developer/docs/integration/mobile/ios-integration-guide/) for
   conceptual information that will be useful during integration.
2. Follow the "Initial setup" instructions in the [iOS Integration Guide](https://developer.paypal.com/webapps/developer/docs/integration/mobile/ios-integration-guide/) to add the
   required files, linker flags, frameworks, and acknowledgments to your app.
3. Add `PayPalMobilePGPlugin.[h|m]` to your project, in the Plugins group
4. Copy `PayPalMobilePGPlugin.js` to your project's `www` folder   
5. Add the following to `config.xml`, for PhoneGap version 3.0+:

   ```xml
     <feature name="PayPalMobile">
       <param name="ios-package" value="PayPalMobilePGPlugin" />
     </feature>
    ```
 
   for older versions under the `plugins` tag:
    
    ```xml
    <plugin name="PayPalMobile" value="PayPalMobilePGPlugin" />
    ```

Sample code
-----------

```javascript

// for simplicity we have defined a simple buyButton in our index.html
// `<button id="buyButton" disabled>Buy Now!</button>`
// and we defined a simple onclick function in our `deviceready` event
var buyButton = document.getElementById("buyButton");
buyButton.onclick = function(e) {

  // See PayPalMobilePGPlugin.js for full documentation
  // set envrionment you want to use
  window.plugins.PayPalMobile.setEnvironment("PayPalEnvironmentNoNetwork");

  // create a PayPalPayment object, usually you would pass parameters dynamically
  var payment = new PayPalPayment("1.99", "USD", "Awesome saws");
  
  // define a callback when payment has been completed
  var completionCallback = function(proofOfPayment) {
    // TODO: Send this result to the server for verification;
    // see https://developer.paypal.com/webapps/developer/docs/integration/mobile/verify-mobile-payment/ for details.
    console.log("Proof of payment: " + JSON.stringify(proofOfPayment));
  }

  // define a callback if payment has been canceled
  var cancelCallback = function(reason) {
    console.log("Payment cancelled: " + reason);
  }
  
  // launch UI, the PayPal UI will be present on screen until user cancels it or payment completed
  window.plugins.PayPalMobile.presentPaymentUI("YOUR_CLIENT_ID", "YOUR_PAYPAL_EMAIL_ADDRESS", "someuser@somedomain.com", payment, completionCallback, cancelCallback);
}
```
