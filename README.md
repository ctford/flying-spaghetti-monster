# Elba
An Idris type provider for communicating type-checkable protocols.

## FFI

Idris Type Providers depend on a foreign function interface. That's turned off by default in the version of Idris on Stack. To install with it enabled:

    stack install idris --flag idris:FFI --flag idris:extra-deps libffi-0.1

## References

* [Multiparty Asynchronous Session Types](http://www.doc.ic.ac.uk/~yoshida/multiparty/multiparty.pdf)
* [Propositions as Sessions](http://homepages.inf.ed.ac.uk/wadler/papers/propositions-as-sessions/propositions-as-sessions-jfp.pdf)
* [Scribble](http://www.scribble.org/)
* [Type-Driven Development of Concurrent Communicating Systems](https://eb.host.cs.st-andrews.ac.uk/drafts/tdd-conc.pdf)
* [Type Providers in Idris](http://docs.idris-lang.org/en/latest/guides/type-providers-ffi.html)
