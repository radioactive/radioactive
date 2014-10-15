Radioactive is a **Native** FRP ( Functional Reactive Programming ) environment for Javascript.

By **Native** we mean that it enables Functional Reactive Programming **at the language level**. You can write plain Javascript code and let Radioactive figure out how and when to deal with **Remote Data Access** and **Change Propagation**.

Within Radioactive everything becomes a function:

* Ajax calls
* Data Streams ( ex: Firebase )
* Static and Mutable data

# Getting Started

## Install

```bash
$ bower install radioactive
```

```bash
$ npm install radioactive
```

## Example

The following snippet shows how easy it is to work with an Ajax datasource, a Firebase stream and a stream of data from an HTML text input.
Notice that we are not using any callbacks or listening to any events.
Yet, somehow, if data changes, the text value of `#output` will be updated accordingly.

```javascript

// radioactive.data exposes popular datasources as reactive streams
// but you can easily write your own
var rates      = radioactive.data("https://openexchangerates.org/api/latest.json?app_id=4a363014b909486b8f49d967b810a6c3&callback=?");
var currency   = radioactive.data("#currency-selector-input");
var bitcoin    = radioactive.data("https://publicdata-cryptocurrency.firebaseio.com/bitcoin/last");

radioactive.react(function(){
  var value =  bitcoin() * rates().rates[currency()];
  $("#output").text( "1 BTC =  " + currency() + " " + value );
})
```

You can completely abstract yourself from "where the data comes from" and "how often it changes" and let [radioactive.react](https://github.com/radioactive/radioactive/wiki/radioactive.react) do all the heavy lifting for you.

This leads to purely functional, highly scalable and mantainable code. You can easily unit test your app or replace parts of your code with mock datasources. Here's how a more modularized version of the previous code might look like:

```javascript
var rates      = radioactive.data("https://openexchangerates.org/api/latest.json?app_id=4a363014b909486b8f49d967b810a6c3&callback=?");
var currency   = radioactive.data("#currency-selector-input");
var bitcoin    = radioactive.data("https://publicdata-cryptocurrency.firebaseio.com/bitcoin/last");

// notice that this function is wrapping an Ajax call and a Firebase stream
// but you can completely abstact yourself from that fact
function getCurrentBitcoinValue( curr ){
  return bitcoin() * rates().rates[curr];
}

radioactive.react(function(){
  $("#output").text( "1 BTC =  " + currency() + " " + getCurrentBitcoinValue( currency() ) );
})
```


You can find more examples on the [/examples](https://github.com/radioactive/radioactive/tree/master/examples) folder.

[radioactive.data](https://github.com/radioactive/radioactive/wiki/radioactive.data) knows how to connect to a series of popular datasources out-of-the box, but the real power of Radioactive is that it is highly extensible. There are many ways to connect your own streams or async services. [Third party integrations](https://github.com/radioactive/radioactive/wiki/Modules) are also available.

Time to read [The Radioactive Tutorial](https://github.com/radioactive/radioactive/wiki/Radioactive-Tutorial).

# What is Radioactive, again?

Depending on where you come from, there are many ways to describe Radioactive.

* A low level library that endows Javascript with low level [FRP ( Functional Reactive Programming )](http://en.wikipedia.org/wiki/Functional_reactive_programming) capabilities.
* An environment where reactive data streams can be treated as first-class Javascript functions.
* A type of data binding solution that isn’t tied to one specific UI framework.
* A minimal API which allows data producers and data consumers built by different teams to interoperate seamlessly and transparently.
* A special kind of async flow control library
* An effort to fix a long standing problem at the level where it should be solved ( at the language core ), once and for all, so we can stop reinventing the wheel and focus on the next set of problems.

Next generation UI frameworks can leverage Radiaoctive as their data-binding layer.
Data source publishers can use Radioactive to provide a more user-friendly API.


# Community

* [github.com/radioactive](https://github.com/radioactive)
* [Google Groups: radioactivejs](https://groups.google.com/forum/#!forum/radioactivejs)
* [meetup.com/radioactive](http://www.meetup.com/radioactive/)
* [Stack Overflow Tag: `[radioactive]`]()
* [radioactive modules and integrations](https://github.com/radioactive/radioactive/wiki/Modules)


