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

The following snippet shows how easy it is to work with an Ajax datasource, Two Firebase streams and a stream of data from an HTML text input.
Notice that we are not using any callbacks or listening to any events.
Yet, somehow, if data changes, the text value of `#output` will be updated accordingly.

```javascript
Ra.react(function(){
  var email      = Ra.data("#some-email-input");
  var user       = Ra.data("http://api.someservice/search-user.json?email=" + email);
  var name       = Ra.data("http://xxx.firebaseio.com/user/" + user.id + "/name");
  var lastname   = Ra.data("http://xxx.firebaseio.com/user/" + user.id + "/lastname");
  $("#output").text( "Hello " + name + " " + lastname )
})
```

And the same example but with a few refactorings:

```javascript
function email2id( email ){
  return Ra.data("http://api.someservice/search-user.json?email=" + email).id
}

function id2fullname( id ){
  var base = "http://xxx.firebaseio.com/user/" + id ;
  return Ra.data( base + "/name") + " " +  Ra.data( base + "/lastname") 
}

Ra.react(function(){
  $("#output").text( "Hello " + id2fullname( email2id( Ra.data("#some-email-input")  ) ) )
})
```

The previous example should illustrate how easy you can abstract yourself from "where the data comes from" and "how often it changes".

[radioactive.data](https://github.com/radioactive/radioactive/wiki/radioactive.data) knows how to connect to a series of datasources out-of-the box, but the real power of Radioactive is that it is highly extensible. 

Time to read [The Radioactive Tutorial](https://github.com/radioactive/radioactive/wiki/Radioactive-Tutorial).

# What is Radioactive, again?

Depending on where you come from, there are many ways to describe Radioactive.

* A low level library that endows Javascript with low level FRP ( Functional Reactive Programming ) capabilities.
* An environment where reactive data streams can be treated as first-class Javascript functions.
* A type of data binding solution that isn’t tied to one specific UI framework.
* A minimal API which allows data producers and data consumers built by different teams to interoperate seamlessly and transparently.
* A special kind of async flow control library
* An effort to fix a long standing problem at the level where it should be solved ( at the language core ), once and for all, so we can stop reinventing the wheel and focus on the next set of problems.

Next generation UI frameworks can leverage Radiaoctive as their data-binding layer.
Data source publishers can use Radioactive to make their offerings more powerful.

This is an API that the browser has been crying for for a long time.


# Community

* [github.com/radioactive](https://github.com/radioactive)
* [Google Groups: radioactivejs](https://groups.google.com/forum/#!forum/radioactivejs)
* [Stack Overflow Tag: `[radioactive]`]()
* [radioactive modules and integrations](https://github.com/radioactive/radioactive/wiki/Modules)



