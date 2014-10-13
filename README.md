Radioactive small layer on top of Javascript that let's you treat all sorts of different datasources as if they were simple functions.
It doesn't matter if your data comes from Ajax calls, from a Firebase stream, from the changing values of a Text Input. From your point of view: **Everything is a Function**.

Using these functions you can write complex data processing and transformation code without using callbacks, listening for events or manually coordinating how the different services work.

Radioactive takes care of managing the complexity behind the curtains:

* If the data is async, it waits for it to arrive
* If data changes, locally or on the server, everything will be updated automatically


# Getting Started

[The Radioactive Tutorial](https://github.com/radioactive/radioactive/wiki/Radioactive-Tutorial)

# What is Radioactive, again?

Depending on where you come from, there are many ways to describe Radioactive.

* A low level library that endows Javascript with low level FRP ( Functional Reactive Programming ) capabilities.
* An environment where reactive data streams can be treated as first-class Javascript functions.
* A better implementation of data binding ( when compared to current UI frameworks such as react, knockout, ember, angular js) that isn’t tied to one specific framework.
* A minimal API which allows data producers and data consumers built by different teams to interoperate seamlessly and transparently.
* An ambitious effort to fix a long standing problem at the level where it should be solved ( at the language core ), once and for all, so we can stop reinventing the wheel and focus on the next set of problems.

Next generation UI frameworks can use Radiaoctive as their data-binding layer.
Data source publishers can use Radioactive to make their offerings more powerful.

This is an API that the browser has been crying for for a long time.


# Community

* [github.com/radioactive](https://github.com/radioactive)
* [Google Groups: radioactivejs](https://groups.google.com/forum/#!forum/radioactivejs)
* [Stack Overflow Tag: `[radioactive]`]()
* [radioactive modules and integrations](https://github.com/radioactive/radioactive/wiki/Modules)



