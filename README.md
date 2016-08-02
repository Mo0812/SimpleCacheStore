# SimpleCacheStore
SimpleCacheStore should allow you to save objects persistent in CoreData and recieve them fast via NSCache when you need them. The basic idea is a key-value store in CoreData with a overlaying cache. Once you save an object in SimpleCacheStore it lays persistent in CoreData and will be also available in the cache of your running instance. Also a not cached object will be saved in the cache when you recieve it for the first time.

## Features
* key-value store
* persistent saving in CoreData
* additional holding used objects in cache for fast recieving

## How to implement SimpleCacheStore
SimpleCacheStore is still under development, so don't use it in production enviorments at the moment. If you want to test or improve it, you're welcome!

To implement SimpleCacheStore just download the repo and open it up in XCode. After that you can create a framework-bundle via the Build function. Then just drag the SimpleCacheStore.framework file into your exisiting project as an embedded library.

## How to use SimpleCacheStore
First you have to import the Library in the files you want to use it:
```swift
import SimpleCacheStore
```
### Save and retrieve objects

After that you can instance the SCManager class and use the following commands:
```swift
let scm = SCManager()
//save an object into SimpleCacheStore
scm.save("KeyX", TestObject("Title 1", subtitle: "Subtitle 1"))
//get an object from SimpleCacheStore
let object = scm.get("KeyX")
```
With the example above you retrieve your stored objects sequentially. There is also a async method to save and retrieve your objects:

**save objects async**

```swift
let scm = SCManager()
//save an object async into SimpleCacheStore
scm?.save(String(i), object: TestObject2(title: "Title" + String(i), image: UIImage(named: "sampleImage")!), answer: {
    success, message in
    //Do work after you know the object has been stored
})
```
**retrieve objects async**

```swift
let scm = SCManager()
//retrieve an object async from SimpleCacheStore
scm?.get(String(i), answer: {
      success, data in
      let obj = data as! TestObject2
      //operate with the object
      print(obj.title)
  })
```

SimpleCacheStore operates the request in a seperate thread via GC.

### SCManager options

When you instance SCManager in your application you can decide between several options.

```swift
let scmanager = SCManager(cacheMode: SCManager.CacheMode, limit: Int)
```

#### 1. cache mode

The cache mode represents how the cache gets initialized on start up of SimpleCacheStore. One of the benefits of SimpleCacheStore is a fast response on requests via a additional cache. So once an object being requested or first get stored SimpleCacheStore also saves it in it's on cache. The next time the same object will be requested SimpleCacheStore retrieve it much faster via the cache and not via CoreData. The additional caching is a simple way to improve the speed of answering requests, but there is also a problem. On every start of SimpleCacheStore the cache is empty. So for the first request of an object you won't get the benefits of additional speed up. To solve this problem we implemented two strategies.

**rebuild mode**
In the rebuild mode SimpleCacheStore reads the whole core data object library and puts every object in the cache. This task will start on the initalizing of SCManager and runs asynchronus, so it won't affect your application on running. The cache gets filled bit by bit. Even own cache fills via get or save commands doesn't get in conflict with this process.

Pro
* fast recovery of the cache over the whole object range
* runs in background and doesn't affect other processes
* fast startup of SimpleCacheStore

Contra
* depending on the core data and cache size, the cache doesn't get filled very clever and you have objects that you may not use
* cache may not filled on first requests (async task)

**snapshot mode**
The snapshot mode takes snapshots of the actual cache and saves it in a several core data object. Because NSCache doesn't allow to transform into binary data, the snapshot mode have to carry a additional Dictionary. When using the snapshot mode you have to ensure to take your own snapshots via ``` scmanager.takeSnapshot() ```. On every start up of SCManager, the system trys to retrieve the latest snapshot. This execution is very fast, but doesn't run async. On the other hand you have two advantages: The last retrieved snapshot may restore a more realistic usage of the cache in your application, and the cache is filled right at the beginning.

Pro
* restored cache set shows a more realistic usage
* cache is ready and filled on startup

Contra
* depending on your set cache size, this process will slow down the execution of your application
* you have to implement snapshot taking on your own in the app
* double amount of RAM needed to carry the information in additional dictionary
* additional disk space for core data needed

Overall the question, which cache mode you uses depends on your working scenario! If you have a small amount of objects in core data (~ 10k-100k) which all fit in SimpleCacheStore's own cache, you should use rebuild mode. If your object library grows all over the place (which we don't recommend - SimpleCacheStore isn't designed to be a data grave) you may can't hold all these objects in the cache memory. Because of the better distribution in these scenario, snapshot mode will be your friend. But please keep in mind that a double memory need may become a problem for your memory too. No matter which mode you use, always keep in mind that SimpleCacheMode adjust it's own cache via request and save commands. So apart from the start up moment, SimpleCacheStore will become more and more specific to what you load from it and saves this in it's cache.

#### 2. cache limit

Cache limit indicates how much objects SimpleCacheStore's cache should hold in your application. You may test it via XCode to look after the RAM utilization and adjust the size of it. Like in the statement above, more cache space for SimpleCacheStore always stands for minor cache misses and faster object delivery. Also keep in mind, that the cache only aquire the space its needed, so a higher value of cache limit won't block more memory. The cache is implemented via NSCache so the object deletion is given by the NSCache class.

## Prepare Objects to get saved to SimpleCacheStore

If you want to store an object in SimpleCacheStore you have to implement the NSCoding protocol. The following code shows you an example:

```swift
import Foundation
import UIKit

class TestObject2: NSObject, NSCoding {
    
    var title: String
    var image: UIImage
    
    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObjectForKey("title") as? String,
            let image = aDecoder.decodeObjectForKey("image") as? UIImage
            else {
                return nil
        }
        
        self.init(title: title, image: image)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.image, forKey: "image")
    }
}
```

SimpleCacheStore treat every given object as NSObject, you have to typecast an retrieving object in your app back to the object type you have store it. This flaw you have to keep in mind. Clear defined keys can help you to manage this.


##Roadmap
- [ ] Singleton instance for SCManager for project-wide easy use
- [x] automatic rebuild cache after creating new instance, for faster first time get-operations
- [x] cache size control and limits
- [ ] get SimpleCacheStore used to secondary indexes

## Why should I use SimpleCacheStore?
The idea of creating SimpleCacheStore is to improve the performance of an self written app (for a university project). This app alwasys fetches informations from a server and has the problem, if no data connection exists the app can't show any content. So my idea was to be able to save downloaded content easily for the case that the data connection gets lost. The second advantage is that slow data connections can also delay the presentation of data in the GUI. So if an app can access (even old) data before the request from the server is answered, it would represent an adavantage too.
