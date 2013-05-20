PayPal iOS SDK Plugin for PhoneGap
---------------------------------

Using PhoneGap for your projects ? now you can use PayPal  iOS SDK in your HTML5+JS project with no effort !

Get started by getting the SDK from https://github.com/paypal/PayPal-iOS-SDK

Integration instructions
------------------------
0. Copy `libPayPalMobile.a` and headers into your project from the SDK
1. Add `PayPalMobilePGPlugin.[h|m]` to your project (Plugins group).  
2. Copy `PayPalMobilePGPlugin` to your project's `www` folder   
3. Add the following to your `config.xml` to your `plugins` tag:  
`<plugin name="PayPalMobile" value="PayPalMobilePGPlugin" />`

### EXAMPLE JS

```
console.log("prepare for payment");
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
