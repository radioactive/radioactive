Radioactive makes working with data easier in Javascript. It unifies different types of datasources and exposes them as simple javascript expressions. You can forget about events and callbacks and write vanilla Javascript code. If data changes, locally or on the server, everything is updated automatically.

* [github.com/radioactive](https://github.com/radioactive)
* Stack Overflow Tag: `[radioactive]`


## The simple explanation:

* Radioactive allows you work with javascript functions that auto-update when their value changes. Most people use it to bind data to a UI, for example. 
* Radioactive also knows how to deal with asynchronous without using callbacks. This allows you to mix and match data coming from any source.

## A more advanced explanation

`reactivity.js` is a cannonical implementation of the [Native Reactivity](https://github.com/aldonline/reactivity/wiki/Native-Reactivity) pattern. It exposes reactive streams of data as pure javascript expressions.
Additionally, in order to reconcile sync and async datasources, radioactive integrates [Forced Execution Suspension](https://github.com/aldonline/reactivity/wiki/Forced-Execution-Suspension) and [Stateful Service Lifecycle Management](https://github.com/aldonline/reactivity/wiki/Stateful-Service-Lifecycle-Management).
The end result is a pure javascript environment where you can transparently mix and match expressions that are reactive, non-reactive, synchronous or asynchronous!

You can essentially represent ANY expression that returns data as a reactive expression.

No more [DonkeyScript](https://www.donkeyscript.org/)!


## Can you show me some examples?

Sure. Here's an example that will print out the time every second:

```javascript
reactivity.react(function(){
  console.log("The current time is " + getTime() )
})
```

The getTime() function is a `radioactive expression`. It returns a value just like a regular function, but it also emits an event whenever its value changes. The `radioactive.react()` function knows how to listen for these events and as soon as they occurr it will re-evaluate whatever it contains.

In order for this to work, the `getTime()` function must `notify` that its value has changed.

... TODO

# Overview

In a very basic sense, Radioactive hast two parts:

* Publish ( use `radioactive.notifier()` )
* Consumer ( use `radioactive.react()` )

We say that a function is radioactive if it can notify us when its value has changed.
( somebody was kind enough to create a radioactive.notifier() under the covers )

# Installation

## NPM

```bash
npm install radioactive
```

```javascript
var radioactive = require('radioactive')

radioactive.react(function(){
  console.log( radioactive.time() );
})
```

## Browser

### Using Bower

```bash
bower install radioactive
```

### Manually

Include the following JS file ( you can find it in /dist/... )

```html
<script src="radioactive.min.js"></script>
```

In the browser, the global `radioactive` object is attached to the root scope ( window )

```javascript
var radioactive = window.radioactive

radioactive.react(function(){
  console.log( radioactive.time() );
})
```

If the object is already present then the library won't mess things up.
It will proxy calls to the pre-existing implementation.


![Radioactive JS](https://dl.dropboxusercontent.com/u/497895/radioactivejs.org/radioactive-js-logo.png "Radioactive JS")
