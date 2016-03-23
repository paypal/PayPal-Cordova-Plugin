PayPal Cordova Plugin Release Notes
===================================

3.1.24
------
* iOS: Update SDK to [2.14.0](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.14.0)
* iOS: Support for right to left language layouts in iOS 9
* iOS: Fix for dynamic text in prices
* Android:  Updated `minSdkVersion` to 16.  This is the minimum Android version to communicate over TLSv1.2, which is required to support [a Payment Card Industry (PCI) Council mandate](http://blog.pcisecuritystandards.org/migrating-from-ssl-and-early-tls). All organizations that handle credit card information are required to comply with this standard. As part of this obligation, [PayPal is updating its services](https://github.com/paypal/tls-update) to require TLSv1.2 for all HTTPS connections. To override the minSdkVersion, please see [the readme](https://github.com/paypal/PayPal-Android-SDK/blob/master/README.md#override-minsdkversion).
* Android: Update okhttp dependency to 3.2.0.
* Android: Fixes issue related to non-ascii characters in user agent [#271](https://github.com/paypal/PayPal-Android-SDK/issues/271).

3.1.23 
------
* Android: Update okhttp dependency to 3.1.2.
* Android: Really fixes issue related to okhttp 3.1.2 [#258](https://github.com/paypal/PayPal-Android-SDK/issues/258).
* Andriod: added bnCode value to payment call

3.1.22 
------
* iOS : Update SDK to [2.13.1](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.13.1)
* iOS : Update card.io dependency to [5.3.1](https://github.com/card-io/card.io-iOS-SDK/releases/tag/5.3.1)
* Android: Fix issue preventing the SDK from app-switching to newer versions of the PayPal App.

3.1.21 
------
* iOS : Update SDK to [2.13.0](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.13.0)
* Android : Fix sandbox pinning issue [#228](https://github.com/paypal/PayPal-Android-SDK/issues/228)
* Android : Clean up manifest permissions [#233](https://github.com/paypal/PayPal-Android-SDK/issues/233)
* Android : Update okhttp dependency to 3.0.1
* Android : Update card.io to 5.3.0

3.1.20
------
* Update Android SDK to [2.12.4](https://github.com/paypal/PayPal-Android-SDK/releases/tag/2.12.4)

3.1.19
------
* Update iOS SDK to [2.12.7](https://github.com/paypal/PayPal-iOS-SDK/releases/tag/2.12.7)
