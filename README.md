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
5. Add the following to `config.xml`, under the `plugins` tag:
    <plugin name="PayPalMobile" value="PayPalMobilePGPlugin" />


Sample code
-----------

```javascript
window.plugins.PayPalMobile.setEnvironment("mock");

var buyButton = document.getElementById("buyButton");
buyButton.disabled = false;
buyButton.onclick = function(e) {
  var payment = new PayPalPayment("1.99", "USD", "Awesome saws");
  
  var completionCallback = function(proofOfPayment) {
    // TODO: Send this result to the server for verification;
    // see https://developer.paypal.com/webapps/developer/docs/integration/mobile/verify-mobile-payment/ for details.
    console.log("Proof of payment: " + JSON.stringify(proofOfPayment));
  }

  var cancelCallback = function(reason) {
    console.log("Payment cancelled: " + reason);
  }
  
  window.plugins.PayPalMobile.presentPaymentUI("YOUR_CLIENT_ID", "YOUR_PAYPAL_EMAIL_ADDRESS", "someuser@somedomain.com", payment, completionCallback, cancelCallback);
}
```
