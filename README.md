# WatchKitCore
The core logic &amp; assets for Highstreet WatchKit Apps

This repository consists of two parts: the code for `WatchKitExtensionCore.framework`, built using the `WatchkitExtensionCore.xcworkspace` and the assets for the WatchKit App target (storyboard, PNG sequences and other assets). 

To see this code in action, check out [https://github.com/GetHighstreet/HighstreetWatchApp](the example project).

# Project Outline
With Highstreet, we’re building a platform for shopping apps. There is what we call the ‘Highstreet iOS Core’, containing all business logic and interface code for the iPhone & iPad app. The core is imported in each client project, where it is configured for that specific client. As a result, our customers all get an app that looks and feels like their brand, but the app shared 99% of the code with other Highstreet apps.

With the introduction of Apple Watch, we’ve created a second ‘core’ that is used for all Highstreet WatchKit apps. We call this the `WatchKitExtensionCore` framework (this repository), which is linked with the WatchKit Extension target in every client project. This repository also contains the storyboard and assets that are installed on the watch.

Because the WatchKit app code is only part of our platform, the structure might seem a little bit more complex than a stand-alone app would be. The following diagram should shed light on the overall structure of our platform and the parts that are open source now:

![Highstreet platform architecture](Documentation/Assets/highstreet_platform_arch.png)

# License
All code is available under the MIT License. All other assets are available under the CC BY 4.0 License.