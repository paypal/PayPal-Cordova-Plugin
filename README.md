# PayPal iOS SDK PhoneGap Plug-in


Integration
-----------
0. Download the [PayPal iOS SDK](https://github.com/paypal/PayPal-iOS-SDK)
1. Copy `libPayPalMobile.a` and headers from the SDK into your project
2. Add `PayPalMobilePGPlugin.[h|m]` to your project, in the Plugins group
3. Copy `PayPalMobilePGPlugin.js` to your project's `www` folder   
4. Add the following to `config.xml`, under the `plugins` tag:
    <plugin name="PayPalMobile" value="PayPalMobilePGPlugin" />


Sample code
-----------

```javascript
window.plugins.PayPalMobile.setEnvironment("mock");
window.plugins.PayPalMobile.prepareForPayment("my client id");

var buyBtn = document.getElementById("buyBtn");
buyBtn.disabled = false;
buyBtn.onclick = function(e) {
  var payment = new PayPalPayment("1.99", "USD", "my payment details");
  
  var resultCallback = function(result) {
    console.log("payment result :" + JSON.stringify(result));
  }
  var cancelCallback = function(reason) {
    console.log("payment cancelled :" + reason);
  }
  
  console.log("launching paypal payment library");
  window.plugins.PayPalMobile.payment("my client id", "myemail@myemail.com", "myref", payment, resultCallback, cancelCallback);
}
```
