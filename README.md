# Flying Spaghetti Monster
An Idris type provider for communicating type-checkable protocols.

![Image of the Flying Spaghetti Monster](https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Touched_by_His_Noodly_Appendage_HD.jpg/320px-Touched_by_His_Noodly_Appendage_HD.jpg "Touched by His Noodly Appendage by Niklas Jansson")


## Usage

This is a verified session using the protocol described in [`vending-machine.txt`](vending-machine.txt) :
```idris
-- A session type that enforces valid interactions with a vending machine.
%provide (VendingMachineSession : (Path -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended")
vendingMachine = do
--Action "hack" -> Won't compile as it's not a legal action described in vending-machine.txt.
  Action "pay"
  Action "return"
--Action "vend" -> Won't compile as it's not a legal action *in this state*.
  Action "pay"
  Action "select"
  Action "vend"
```

See [`Example.idr`](Example.idr) for more detail.

## FFI

Idris Type Providers depend on a foreign function interface. That's turned off by default in the version of Idris on Stack. To install with it enabled:

    stack install idris --flag idris:FFI --flag idris:extra-deps libffi-0.1

## Todo

- [x] Generate a finite state machine type from data.
- [x] Supply the type via a type provider.
- [x] Get the type error messages as good as they were before I started abstracting everything.
- [ ] Read the list of valid steps over HTTP.
- [ ] Set up a sample protocol registry.

## References

* [Multiparty Asynchronous Session Types](http://www.doc.ic.ac.uk/~yoshida/multiparty/multiparty.pdf)
* [Propositions as Sessions](http://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-sessions/propositions-as-sessions-jfp.pdf)
* [Scribble](http://www.scribble.org/)
* [Type-Driven Development of Concurrent Communicating Systems](https://eb.host.cs.st-andrews.ac.uk/drafts/tdd-conc.pdf)
* [Type Providers in Idris](http://docs.idris-lang.org/en/latest/guides/type-providers-ffi.html)
