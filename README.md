## Librato Client

Analyze your frontend UI with LibratoClient. You can easily count, measure or
time any event and submit it to Librato for graphing and alerts.

## Getting Started

1. Create a server route for collecting UI metrics
2. Setup LibratoClient in your frontend application


### Create the server side route

The LibratoClient sends a JSON payload that looks something like this:

```
{ type: 'timing',
  metric: 'ui.window.onload',
  source: 'mac.chrome.46',
  value: 1342 }
```

Now let's create a route handler that extracts data from the payload,
repackages it, and submits it to Librato using one of our collector agents.
Let's assume we're using Ruby on Rails and we're using
[librato-rails](http://github.com/librato/librato-rails).

We'll need to route an endpoint e.g. `/collect` to a route handler that submits
our UI metrics to Librato.

The route looks something like this:

```ruby
Rails.application.routes.draw do
  post '/collect' => 'collection#collect'
end
```

The controller will look something like this:

```ruby
class CollectionController < ApplicationController

  def collect
    type      = params.delete 'type'
    metric    = params.delete 'metric'
    value     = params.delete 'value'
    source    = params.delete 'source'
    options   = { source: source }
    increment_options = { by: value,
                          sporadic: true,
                          source: options[:source] }

    case type
    when 'increment' then Librato.increment metric, increment_options
    when 'timing'    then Librato.timing    metric, value, options
    when 'measure'   then Librato.measure   metric, value, options
    end
    head :ok
  end
end
```

### Setup LibratoClient in your frontend application

Create the librato client somewhere near to the beginning of the page. The
librato client library is small.

```javascript
librato = new LibratoClient({
  endpoint: '/collect',
  prefix: 'ui',
  source: 'platform.browser.version',
});
```

Once we create the client we can begin using it to submit metrics to our endpoint.

```javascript
window.onload = librato.timing('window.onload')
```

When `window.onload` invokes the timer it will POST the following payload to our
`/collect` endpoint:

```
{ type: 'timing',
  metric: 'ui.window.onload',
  source: 'mac.chrome.46',
  value: 30 }
```

The LibratoClient works well in a component based archetectiure. For example
let's assume we have a modal. In the modal we are able to send a message. There
are a few things we want to measure with our new modal.

1. Count when the modal opens
2. Count when the modal closes
3. Time how long it takes to submit a message
4. Measure the length of the message
5. Count if the user wasn't able to send a message

```javascript
function MessageModal() {
  this.librato   = librato.metric('modal.message');
  this.messenger = new Messenger()
}

MessageModal.prototype = {

  open: function() {
    // Open the modal ...

    this.librato.increment('toggle', { source: 'open' });

    /* Would send this payload to /collect:
     *  { type: 'increment',
     *    metric: 'ui.modal.message.toggle',
     *    source: 'open',
     *    value: 1 }
     */
  },

  close: function() {
    // Close the modal ...

    this.librato.increment('toggle', { source: 'close' });

    /* Would send this payload to /collect:
     *  { type: 'increment',
     *    metric: 'ui.modal.message.toggle',
     *    source: 'close',
     *    value: 1 }
     */
  },

  submit: function(message) {
    this.messenger.send(message)

      .then(librato.timing('time'))
      /* If the request is successful our timer will send the following payload
       * to the server:
       *  { type: 'timing',
       *    metric: 'ui.modal.message.time',
       *    source: 'mac.chrome.46',
       *    value: 435 }
       */

      .catch(librato.increment('submit.error'))
      /* If the request is unsuccessful our incrementer will send the following payload
       * to the server:
       *  { type: 'increment',
       *    metric: 'ui.modal.message.submit.error',
       *    source: 'mac.chrome.46',
       *    value: 1 }
       */

      .finally(function(){
        librato.measure('length', message.length);
        /* Under any condition we'll send the message length to the server.
         *  { type: 'measure',
         *    metric: 'ui.modal.message.length',
         *    source: 'mac.chrome.46',
         *    value: 14 }
         */
        this.close();
      });
  }
};
```

### Configuring and forking the client

The librato client can update and change its configuration at any time. A new
client is returned each time the settings are modified. Invoking `metric` or
`source` does not mutate the original settings of your librato client instance.

You can think of the `metric` method as a base metric. Sometimes it is helpful
to categorize metric names. For example, if we had both AWS EC2 and AWS ELB
metrics we'd use `AWS` as a metric base.

    AWS.EC2.CPUUtilization
    AWS.ELB.CPUUtilization

```javascript
librato.metric('foo').increment('bar');   // metric=foo.bar, value=1
librato.metric('foo').increment();        // metric=foo,     value=1
```

You'll have to save the returned client if you want to use it with any of the
new settings.

```javascript
tracker = librato.metric('foo')
tracker.increment('bar')                  // metric=foo.bar, value=1
librato.increment('bar')                  // metric=bar,     value=1
tracker === librato                       // false
```


We have a several types of instruments: `increment`, `measure`, and `timing`.
The LibratoClient is flexible and these insruments may be invoked in various
ways.


### Increment

You may use any of the following strategies for incrementing the metric `foo.count`.

```javascript
librato.increment('foo.count');                  // metric=foo.count, value=1, source=
librato.increment('foo.count', 5);               // metric=foo.count, value=5, source=
librato.increment('foo.count', { value: 5 });    // metric=foo.count, value=5, source=
```

You may also set a specific source:

```javascript
librato.increment('foo.count', { value: 5, source: 'bar' }); // metric=foo.count, value=5, source=bar
```

The increment is also curryable, so you can partially apply the metric name and
send the counter later.

```javascript
foo = librato.metric('foo')

foo.increment();                                         // metric=foo,       value=1, source=
foo.increment(5);                                        // metric=foo,       value=5, source=
```

When you curry the increment you can also apply a base metric name. It is
helpful to use a base metric if you are instrumenting several different
metrics.

```javascript
foo = librato.metric('foo')

foo.increment('count');                                  // metric=foo.count, value=1, source=
foo.increment('count', 5);                               // metric=foo.count, value=5, source=
foo.increment('count', { value: 5 });                    // metric=foo.count, value=5, source=
foo.increment('count', { value: 5, source: 'baz' });     // metric=foo.count, value=5, source=baz
```

If you simply want to increment by one you can pass the increment instrument to
a callback. The increment count is collected when the callback is invoked.

```javascript
successCount = librato.metric('foo.count')
errorCount   = librato.metric('foo.error.count')

SomePromise().then(doSomething)
             .then(doSomethingElse)
             .then(successCount)    // Increment on success
             .catch(errorCount)     // Increment error on failure
```

### Measure

You may use any of the following strategies to measure a metric.

```javascript
librato.measure('foo', 5);                           // metric=foo, value=5, source=
librato.measure('foo', { value: 5 });                // metric=foo, value=5, source=
librato.measure('foo', { value: 5, source: 'bar' }); // metric=foo, value=5, source=bar
```

#### curry

```javascript
foo = librato.measure('foo')

foo.measure(9)                   // metric=foo, value=9, source=
foo.measure(8)                   // metric=foo, value=8, source=
```

### Timing

The timing instrument collects a timing measure. You may use the timing
instrument in various ways.

You may explicitely send a timing measure directly.

```javascript
librato.timing('foo.timing', 2314);                           // metric=foo, value=2314, source=
librato.timing('foo.timing', { value: 2314 });                // metric=foo, value=2314, source=
librato.timing('foo.timing', { value: 2314, source: 'bar' }); // metric=foo, value=2314, source=bar
```

You may partially evaluate a timing measure and send automatically calculate
the time.

```javascript
window.onload = librato.timing('window.onload')      // metric=window.onload, value=1432, source=
```

You may partially evaluate a timing measure and send send the time explicitly.

```javascript
foo = librato.metric('foo')
timer = foo.timing('time')

// FIXME
getFoos = function() {
  getAsync().then(timer).then
}
foo.timing('time', 324)                                       // metric=foo, value=324, source=
```

You may time a callback function. The first parameter in the callback function
is a callback. Invoke the callback method when you are finished timing and
ready to send the timing measurement.

```javascript
librato.timing('foo', function(done){
  doSomethingAsync(function(result){
    somethingElse(result);
    done();                                          // metric=foo, value=1432, source=
  });
});
```

You may also omit the metric and call the timing instrument with a value or a
function as the second parameter. It is helpful to use this strategy when you
are measuring several related metrics in the same location.

```javascript
// Cloning foos
function Foo() {
  this.librato = librato.metric('foo');
}

Foo.prototype.all = function() {
  return Things.all();
}

Foo.prototype.clone = function() {
  this.librato.increment('count')          // metric=foo.count, value=1, source=
}
```
