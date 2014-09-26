/*

Adding radioactivity to any data producing framework is easy and can be achieved
with a few lines of code.

The following snippet is all that it takes to make Firebase fully radioactive.
All 'Firebase' instances will now have an R(2) get() method.

TODO: GC listeners

Installation:
To use this just make sure to add this after both Firebase and radioactive have been loaded

Usage:

var ref = new Firebase("https://.../")

radioactive(function(){

    console.log( ref.get().toUpperCase() )

})

*/
(function(){
    var cells = {};
    Firebase.prototype.get = function(){
        var url = this.toString();
        var ref = this;
        return ( cells[url] || (cells[url] = (function(){
            var cell = radioactive( new radioactive.WaitSignal );
            ref.on('value', function( snap ){ cell( snap.val() ) });
            return cell;
        })()))()
    }
})();