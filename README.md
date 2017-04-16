# Flying Spaghetti Monster
An [Idris](http://www.idris-lang.org/) type provider for communicating type-checkable protocols.

![Image of the Flying Spaghetti Monster](https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Touched_by_His_Noodly_Appendage_HD.jpg/320px-Touched_by_His_Noodly_Appendage_HD.jpg "Touched by His Noodly Appendage by Niklas Jansson")


## Usage

This is a verified session using the protocol described in [`vending-machine.txt`](./example/vending-machine.txt):
```idris
%provide (VendingMachineSession : (Route -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", const "waiting")
vendingMachine = do
  --`Do "hack"` wouldn't compile, because it's not a legal action described in vending-machine.txt.
  Do "insert-coin"
  --`Do "vend"` wouldn't compile, because it's not a legal action *in this state*.
  Do "insert-coin"
  -- Some actions can fail, in which case the compiler checks all the paths end in the right state.
  Success <- Try "select" | Failure => do Do "return"; Fail
  Do "vend"
```

If you try and use the illegal action `"hack"`, you'll get the following *compilation* error:

```
Example.idr:27:10:When checking right hand side of vendingMachine with expected type
        VendingMachineSession ("waiting", "vended")

When checking argument membership to constructor Protocol.Action:
        Can't find a value of type
                Elem "hack" ["insert-coin", "return", "select", "vend"]
```

The Idris compiler reads the description of the protocol and then type checks it. Even though the actions are specified by strings, Idris is able to verify that they're within the set of actions specified.

But that's not all. The Idris compiler is able to type check that the order of the actions fits the specified protocol. If you try and use the legal action `"vend"` at the wrong time, you'll get another *compilation* error.

It's a little long, but it clearly indicates that there's no `"vend"` action that has the appropriate source and destination states:

```
Example.idr:31:3:When checking right hand side of vendingMachine with expected type
        VendingMachineSession ("waiting", "vended")

When checking an application of constructor Protocol.>>=:
        Type mismatch between
                Command ()
                        (Choice [("insert-coin", "waiting", "paid"),
                                 ("return", "paid", "waiting"),
                                 ("select", "paid", "selected"),
                                 ("vend", "selected", "vended")])
                        (locate "vend"
                                [("insert-coin", "waiting", "paid"),
                                 ("return", "paid", "waiting"),
                                 ("select", "paid", "selected"),
                                 ("vend", "selected", "vended")])
                (Type of Action "vend")
        and
                Command ()
                        (Choice [("insert-coin", "waiting", "paid"),
                                 ("return", "paid", "waiting"),
                                 ("select", "paid", "selected"),
                                 ("vend", "selected", "vended")])
                        ("waiting", "waiting")
                (Expected type)

        Specifically:
                Type mismatch between
                        locate "vend" [("pay", "waiting", "paid"),
                                       ("return", "paid", "waiting"),
                                       ("select", "paid", "selected"),
                                       ("vend", "selected", "vended")]
                and
                        ("waiting", "waiting")

Unification failure
```

See [the example](./example) for more detail.

## FFI

Idris Type Providers depend on a foreign function interface. That's turned off by default in the version of Idris on Stack. To install with it enabled:

    stack install idris --flag idris:FFI --flag idris:extra-deps libffi-0.1

## Building

You can build the example:
```
$ ./build
$ ./runexample
```

## Todo

- [x] Generate a finite state machine type from data.
- [x] Supply the type via a type provider.
- [x] Get the type error messages as good as they were before I started abstracting everything.
- [x] Support transitions that can fail.
- [ ] Read the list of valid steps over HTTP.
- [ ] Use error reflection to improve error reporting.
- [x] Package it.
- [ ] Set up a sample protocol registry.

## References

* [Multiparty Asynchronous Session Types](http://www.doc.ic.ac.uk/~yoshida/multiparty/multiparty.pdf)
* [Propositions as Sessions](http://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-sessions/propositions-as-sessions-jfp.pdf)
* [Scribble](http://www.scribble.org/)
* [Type-Driven Development of Concurrent Communicating Systems](https://eb.host.cs.st-andrews.ac.uk/drafts/tdd-conc.pdf)
* [Type-Driven Development with Idris](https://www.manning.com/books/type-driven-development-with-idris)
* [Type Providers in Idris](http://docs.idris-lang.org/en/latest/guides/type-providers-ffi.html)
