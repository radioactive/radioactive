Radioactive is a Javascript API that unifies different types of datasources ( sync, async, streaming ) and exposes them as regular Javascript functions. 

You can write complex data processing and transformation code without using callbacks, listening for events or manually coordinating how the different services work. From your point of view, every service is represented by a synchronous Javascript function.

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

# Community

* [github.com/radioactive](https://github.com/radioactive)
* [Google Groups: radioactivejs](https://groups.google.com/forum/#!forum/radioactivejs)
* [Stack Overflow Tag: `[radioactive]`]()
* [radioactive modules and integrations](https://github.com/radioactive/radioactive/wiki/Modules)



