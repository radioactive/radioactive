Radioactive small layer on top of Javascript that lets you treat all sorts of different datasources as if they were simple functions.
It doesn't matter if your data comes from remote AJAX calls, from a Firebase stream, or if it represents the changing value of a Text Input. From your point of view: **Everything is a Function**.

Once you can see all of your datasources as functions you are free to write complex data processing and transformation code without using callbacks, listening for events or manually coordinating how the different services work. If data changes, locally or on the server, everything will be updated automatically

# Getting Started

## Install

```bash
$ bower install radioactive
```

```bash
$ npm install radioactive
```

## 5 Minute Tour

The following snippet shows how easy it is to work with an Ajax datasource, a Firebase stream and a stream of data from an HTML text input.
Notice that we are not using any callbacks or listening to any events.
Yet, somehow, if data changes, the text value of `#output` will be updated accordingly.

```javascript
radioactive.react(function(){
  var currency   = radioactive.data("#currency-selector-input");
  var rates      = radioactive.data("https://openexchangerates.org/api/latest.json?app_id=4a363014b909486b8f49d967b810a6c3&callback=?");
  var bitcoin    = radioactive.data("https://publicdata-cryptocurrency.firebaseio.com/bitcoin/last");
  $("#output").text( "1 BTC =  " + currency + " " + bitcoin * rates[currency] );
})
```

You can see how easy you can abstract yourself from "where the data comes from" and "how often it changes". The reactive loop does all the heavy lifting for you.

The beauty of working with functions is that you can easily refactor and modularize your code. You then "assemble" the final expression you want to work with inside the radioactive.react() loop.

This leads to purely functional, highly scalable and mantainable code. You can easily unit test your app or replace parts of your code with mock datasources. Here's how a more modularized version of the previous code might look like:


```javascript
function getRate( currency ){
  return radioactive.data("https://openexchangerates.org/api/latest.json?app_id=4a363014b909486b8f49d967b810a6c3&callback=?").rates[currency];
}
function getSelectedCurrency(){
  return radioactive.data("#currency-selector-input");
}
function getLatestBitcoinValue(){
  return radioactive.data("https://publicdata-cryptocurrency.firebaseio.com/bitcoin/last");
}

radioactive.react(function(){
  $("#output").text( "1 BTC =  " + currency + " " + getLatestBitcoinValue() * getRate( currency ) );
})
```

You can find this example on the `/examples` folder.

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
* [meetup.com/radioactive](https://www.meetup.com/radioactive/)
* [Stack Overflow Tag: `[radioactive]`]()
* [radioactive modules and integrations](https://github.com/radioactive/radioactive/wiki/Modules)


