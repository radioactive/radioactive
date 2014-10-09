Radioactive makes working with data easier in Javascript. It unifies different types of datasources and exposes them as simple javascript functions. You can forget about events and callbacks and write vanilla Javascript code. If data changes, locally or on the server, everything is updated automatically.

* If you want to learn more about the project and our mission, read this introductory blog post.
* If you want to use radioactive, just keep on reading

# Quickstart

```bash
npm install radioactive
```

```javascript
var radioactive = require('radioactive')

radioactive.react(function(){
  console.log( radioactive.time() );
})
```

You can also install it using bower.

```bash
bower install radioactive
```

Radioactive exposes one global object called `radioactive`.

```javascript

radioactive.react(function(){
  console.log( radioactive.time() );
})
```

[Head on to the Tutorial](https://github.com/radioactive/radioactive/wiki/Tutorial)


# Community

* [github.com/radioactive](https://github.com/radioactive)
* [Google Groups: radioactivejs](https://groups.google.com/forum/#!forum/radioactivejs)
* [Stack Overflow Tag: `[radioactive]`]()




