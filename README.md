## Librato Client

[![Build Status](https://travis-ci.org/luk3thomas/librato-client.svg)](https://travis-ci.org/luk3thomas/librato-client)

Analyze your frontend UI with LibratoClient. You can easily count, measure or
time any event and submit it to Librato for graphing and alerts.

## Getting Started

The LibratoClient is a frontend, JavaScript library designed to report metrics
from your UI to a server side [collection
agent](https://www.librato.com/product/collection-agents). You'll need to
configure your server side collection agent to send the actual metrics to
Librato.

1. Create a server route for collecting UI metrics
2. Setup LibratoClient in your frontend application

### Create the server side route

The LibratoClient sends a JSON payload with four keys: `type`, `metric`,
`source`, and `value`. The payload will look something like this:

```
{ type: 'timing',
  metric: 'ui.window.onload',
  source: 'mac.chrome.46',
  value: 1342 }
```

First, create a route handler that extracts data from the payload, and submits
it to Librato.  Let's assume we're using Ruby on Rails and we're using the
[librato-rails](http://github.com/librato/librato-rails) collection agent.

We'll need to route an endpoint, `/collect` to a route handler that submits
our UI metrics to Librato.

```ruby
Rails.application.routes.draw do
  post '/collect' => 'collection#collect'
end
```

The UI client sends a rather generic payload. In our route handler we'll
repackage the data and submit it to the appropriate Librato instrument.

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

Now that we created a route we can add LibratoClient to our UI. Create the
librato client somewhere near to the beginning of the page.

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
  value: 986 }
```

That's it!

### Advanced Example

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
  this.librato   = librato.metric('modal.message');  // Sets the base metrics to `modal.message`
  this.messenger = new Messenger()
}

MessageModal.prototype = {

  open: function() {
    // Open the modal ...

    // Count when the modal opens
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

    // Count when the modal closes
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

      // Time how long it takes to submit a message
      .then(librato.timing('time'))
      /* If the request is successful our timer will send the following payload
       * to the server:
       *  { type: 'timing',
       *    metric: 'ui.modal.message.time',
       *    source: 'mac.chrome.46',
       *    value: 435 }
       */

      .catch(function() {

        // Count if the user wasn't able to send a message
        librato.increment('submit.error')
        /* If the request is unsuccessful our incrementer will send the
         * following payload to the server:
         *  { type: 'increment',
         *    metric: 'ui.modal.message.submit.error',
         *    source: 'mac.chrome.46',
         *    value: 1 } */
      })

      // Measure the length of the message
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

## Instruments

The LibratoClient has three instruments `increment`, `measure`, and `timing`.
All instruments are very flexible and are able to be used in several different
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
successCount = librato.metric('foo.success.count')
errorCount   = librato.metric('foo.error.count')

SomePromise().then(doSomething)
             .then(doSomethingElse)
             .then(successCount)    // Increment on success
             .catch(errorCount)     // Increment error on failure
```

### Measure

The measure instrument is similar to the increment instrument except it expects
a value in the second parameter.

```javascript
librato.measure('foo', 5);                                    // metric=foo, value=5, source=
librato.measure('foo', { value: 5 });                         // metric=foo, value=5, source=
librato.measure('foo', { value: 5, source: 'bar' });          // metric=foo, value=5, source=bar

librato.metric('foo').measure(5);                             // metric=foo, value=5, source=
librato.metric('foo').measure({ value: 5 });                  // metric=foo, value=5, source=
librato.metric('foo').measure({ value: 5, source: 'bar' });   // metric=foo, value=5, source=bar
```

The measure method is also curryable. You can all the measure method with a
metric name, and then you may call it a second time with the value. The measure
instrument will not send data to the endpoint until it has both a metric and a
value.

```javascript
foo = librato.measure('foo')

foo.measure(9)                   // metric=foo, value=9, source=
foo.measure(8)                   // metric=foo, value=8, source=
```

### Timing

The timing instrument collects a timing measure. You may partially evaluate a
timing measure and send automatically calculate the time.

```javascript
window.onload = librato.timing('window.onload')                 // metric=window.onload, value=1432, source=
window.onload = librato.source.('foo').timing('window.onload')  // metric=window.onload, value=1432, source=foo
```

You may partially evaluate a timing measure and send send the time explicitly.
The next time the timer is invoked it will calculate the time difference in
milliseconds and send it to the endpoint.

Invoking with a promise:

```javascript
done = librato.metric('foo').timing('time');

getAsync().then(done);                               // metric=foo.time,  value=231
```

Invoking as a callback:

```javascript
// or as a callback
done = librato.metric('foo').timing('time');

getAsync(function(results) {
  doSomething(results);
  done();                                            // metric=foo.time,  value=231
});
```

You may also time blocks of code. The first parameter is a function `done`.
When you invoke `done` the timing instrument will send metrics to `/collect`.

```javascript
librato.timing('foo', function(done){
  doSomethingAsync(function(result){
    somethingElse(result);
    done();                                          // metric=foo, value=1432, source=
  });
});
```

You may explicitely send a timing measure directly.

```javascript
librato.timing('foo.timing', 2314);                           // metric=foo, value=2314, source=
librato.timing('foo.timing', { value: 2314 });                // metric=foo, value=2314, source=
librato.timing('foo.timing', { value: 2314, source: 'bar' }); // metric=foo, value=2314, source=bar

librato.metric('foo').timing(2314);                           // metric=foo, value=2314, source=
librato.metric('foo').timing({ value: 2314 });                // metric=foo, value=2314, source=
librato.metric('foo').timing({ value: 2314, source: 'bar' }); // metric=foo, value=2314, source=bar
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


