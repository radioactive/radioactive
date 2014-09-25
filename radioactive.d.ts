
declare module "radioactive" {

    /**
     * Returns a cell initialized to undefined
     */
    function r(): r.Cell<any>;

    /**
     * Proxies to loop() when called with one argument of type function
     */
    function r( f: () => any ) : void;

    /**
     * Returns a cell initialized to @value when called with one argument that is not a function
     */
    function r<T>( value: T ): r.Cell<T>;


    module r {

        function active(): boolean;

        /**
         * Request a Notifier.
         * This method may return null if you are not running
         * within a reactive function.
         * NOTE: This function may return undefined.
         *
         * Why? Because Setting up Notifiers
         * usually requires allocating resources ( timers, event listeners )
         * that are expensive.
         *
         */
        function notifier(): Notifier;

        function fork(): Forker;

        function cell<T>(): Cell<T>;

        function cell<T>( v:T ): Cell<T>;


        /**
         * Throws a StopSignal
         */
        function stop(): void;


        function react( f: () => any ): Stopper;

        function react<T>( f: () => T, cb: ( e?: Error, r: T ) => void ): Stopper;

        function once<T>( f: () => T, cb: ( e?: Error, r: T ) => void ): Stopper;



        function waiting( f: () => any ): boolean;

        /**
         * Throws a WaitSignal
         */
        function wait(): void;


        function syncify( async: Function ): Function;

        function syncify( opts: SyncifyOpts ): Function;

        interface SyncifyOpts {

            /**
             * Force expiration of cached results after N milliseconds.
             * Defaults to 0 ( = infinite ).
             * If you want to achieve polling functionality.
             */
            ttl?: number ;

            /**
             *
             * @param args
             */
            hasher?: ( args: Array<any> ) => string ;


            /**
             *
             */
            global?: boolean ;


            func: Function ;

        }





        function echo( delay: number = 1000 ): ( string ) => void;


        function time( interval: number = 1000 ): number;

        /**
         * Takes a R(>0) expression and makes it R(0)
         * @param expr
         */
        function mute<T>( expr: () => T ): () => T

        /**
         *
         */
        interface Notifier {
            /**
             * Shortcut for fire()
             */
            (): void
            cancel(): void
            fire(): void
        }

        interface Stopper {
            /**
             * Stop this watcher.
             */
            (): void
        }

        interface Forker {
            /**
             * Executes a block of code inside a fork.
             * May return null a few times before returning
             * the actual value.
             */
            <T>( block: () => T ): T

            /**
             * Waits until all forked blocks of code are finished
             */
            join(): void
        }

        /**
         A Cell is a "Reactive Variable".
         You can put anything you want in it by calling `cell( value )` ( one parameter )
         and then you can get it back by calling cell() ( with no parameters ).

         How do I set a cell to an error state?
         If you pass a value where ( value instanceof Error == true )
         Then the cell will automatically be set to an error state.

         If you wish to pass an error so that it can be stored
         you will need to wrap it into something else.
         */
        interface Cell<T> {
            ( ): T
            get( ): T

            ( v: T ): void
            set( v: T ): void

            ( v: Error ): void
            set( v: Error ): void

            ( e?: Error, v?: T ): void

            /**
             * Whether someone is interested in knowing if our value changes.
             * This may change at any time as the cell may be accessed and notifiers requested.
             */
            monitored():boolean
        }






    }

export = r;
}
