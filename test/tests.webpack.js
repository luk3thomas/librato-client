require('script-loader!sinon/pkg/sinon')
var context = require.context('./', true, /spec\.coffee$/);
context.keys().forEach(context);
