# SimpleCacheStore
SimpleCacheStore should allow you to save objects persistent in CoreData and recieve them fast via NSCache when you need them. The basic idea is a key-value store in CoreData with a overlaying cache. Once you save an object in SimpleCacheStore it lays persistent in CoreData and will be also available in the cache of your running instance. Also a not cached object will be saved in the cache when you recieve it for the first time.

## Features
* key-value store
* persistent saving in CoreData
* additional holding used objects in cache for fast recieving

## How to implement SimpleCacheStore
SimpleCacheStore is still under development, so dont't use it in production enviorments at the moment. If you want to test or improve it, you're welcome!

To implement SimpleCacheStore just download the repo and open it up in XCode. After that you can create a framework-bundle via the Build function. Then just drag the SimpleCacheStore.framework file into your exisiting project as an embedded library.

## How to use SimpleCacheStore
First you have to import the Library in the files you want to use it:
```swift
import SimpleCacheStore
```
After that you can instance the SCManager class and use the following commands:
```swift
let scm = SCManager()
//save an object into SimpleCacheStore
scm.save("KeyX", TestObject("Title 1", subtitle: "Subtitle 1"))
//get an object from SimpleCacheStore
let object = scm.get("KeyX")
```
There are also several other methods and a callback paradigma in SimpleCacheStore, they will be discussed later.

##Roadmap
* Singleton instance for SCManager for project-wide easy use
* automatic rebuild cache after creating new instance, for faster first time get-operations
* cache size control and limits
* get SimpleCacheStore used to secondary indexes

## Why should I use SimpleCacheStore?
The idea of creating SimpleCacheStore is to improve the performance of an self written app (for a university project). This app alwasys fetches informations from a server and has the problem, if no data connection exists the app can't show any content. So my idea was to be able to save downloaded content easily for the case that the data connection gets lost. The second advantage is that slow data connections can also delay the presentation of data in the GUI. So if an app can access (even old) data before the request from the server is answered, it would represent an adavantage too.
