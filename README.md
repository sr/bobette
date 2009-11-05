# Bobette — Bob's sister

Bobette is a [Rack](http://rack.rubyforge.org) app that will turn the payload
specified in the `bobette.payload` Rack env key into a buildable object and
then build it using [Bob](http://github.com/integrity/bob).

It also provides middlewares to normalize the payload format used
by code hosting services into a common format:

    {"scm" => "git",
     "uri" => "git@github.com:integrity/integrity",
     "branch" => "master",
     "commits" =>
     [{"id"      => "c6dd001c1a95763b2ea62201b73005a6b86c048e",
       "message" => "Add rip files",
       "author"  => {"name" => "Simon Rozet", :email => "simon@rozet.name"},
       "timestamp" => "2009-09-30T06:16:12-07:00"}]}

Only [GitHub](http://github.com) is supported so fare but it's easy to add
support for other code hosting services.

Checkout [Integrity](http://integrityapp.com) for a full fledged automated
Continuous Integration server.

## Acknowledgement

Thanks a lot to [Tim Carey-Smith](http://github.com/halorgium) for his early
feedback.
