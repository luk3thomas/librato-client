## Librato Client

[![NPM Package Stats](https://nodei.co/npm/librato-client.png)](https://www.npmjs.org/package/librato-client) [![Build Status](https://travis-ci.org/luk3thomas/librato-client.svg)](https://travis-ci.org/luk3thomas/librato-client)

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
`tags`, and `value`. The payload will look something like this:

```
{
  measurements: [
    { type: 'timing',
      metric: 'ui.window.onload',
      tags: { browser: 'chrome' },
      value: 1342 }
  ]
}
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
    measurements = params.delete('measurements')
    measurements.each do |measure|
      type      = measure.delete 'type'
      metric    = measure.delete 'metric'
      value     = measure.delete 'value'
      tags      = measure.delete 'tags'

      case type
      when 'timing'    then Librato.timing    metric, value, tags: tags
      when 'measure'   then Librato.measure   metric, value, tags: tags
      end
    end
    head :ok
  end
end
```

### Setup LibratoClient in your frontend application

Now that we created a route we can add LibratoClient to our UI.

```javascript
librato = new LibratoClient({
  endpoint: '/collect',
  prefix: 'ui',
});
```

Once we create the client we can begin using it to submit metrics to our endpoint.

```javascript
librato.measure('chart.actions', { action: 'add' }, 1)
```

When `window.onload` invokes the timer it will POST the following payload to our
`/collect` endpoint:

```
{ type: 'measure',
  metric: 'ui.chart.actions',
  tags: { action: 'add' },
  value: 1 }
```

That's it!

## Tags

The second argument of all instrumentation methods is an optional set of tags.

```javascript
measure(<metric>, [tags={}, value=1])
timing(<metric>, [tags={}, callback])
```

All key value pairs are sent to your frontend collector as measurement tags,
with the execption of a few reserved tag names.

|Reserved key|Description|
|------------|-----------|
|`$inherit`  | Controls which default tags are included with the measurement|
|`$start_time` | Backdates the start time for a timing measure |

#### `$inherit`

Including `$inherit: true` will merge all default tags specified in the
collector constructor into the current measurment tags. The `$inherit` tag
accepts varied values, boolean, string or array.

```javascript
@client = new LibratoClient({
  tags: {
    app: 'awesome',
    env: 'production',
    browser: 'chrome',
  }
})

// Later on ...

@client.measure('foo', { hello: 'there' })                             // tags={hello: 'there'}
@client.measure('foo', { hello: 'there', $inherit: true })             // tags={hello: 'there', app: 'awesome', browser: 'chrome', env: 'production'}
@client.measure('foo', { hello: 'there', $inherit: 'app' })            // tags={hello: 'there', app: 'awesome'}
@client.measure('foo', { hello: 'there', $inherit: ['app', 'env'] })   // tags={hello: 'there', app: 'awesome', env: 'production'}
```

## Instruments

The LibratoClient has three instruments `measure`, and `timing`.

### Measure

The measure instrument collects a gauge measurement. The value defaults to one.

```javascript
librato.measure('foo.action');                    // metric=foo.action, value=1, tags={}
librato.measure('foo.action', 5);                 // metric=foo.action, value=5, tags={}
librato.measure('foo.action', { a: '1' }, 5);     // metric=foo.action, value=5, tags={a: 1}
```

### Timing

The timing instrument collects a timing measure.

```javascript
done = librato.timing('foo.action', {app: 'awesome'});
DoSomethingAsync.then(done);                                      // metric=foo.action, value=1234, tags={app: 'awesome'}

librato.timing('foo.action', {app: 'awesome'}, function(done){
  // Do some things ...
  done()                                                          // metric=foo.action, value=1234, tags={app: 'awesome'}
});
```

#### Backdating the start time

In the case of a metric like `window.onload` want to measure the time from
first byte until the page loads. One way to do this is to laod the librato
client near the top of the page and attach a timing instrument to the callback.
Obviously that isn't good for performance. We want to load all the scripts near
the bottom of the document.

The timing instrument has the ability to backdate the start time.

In the `<head>` of the document

```html
  <script>
    window._start = new Date();
  </script>
</head>
```

Later on, after we've loaded the library we can use the reserved `$start_time` tag to backdate the start time.

```javascript
window.onload = librato.timing('window.onload', { $start_time: window._start })    // metric=window.onload, value=1432, tags={}
```
