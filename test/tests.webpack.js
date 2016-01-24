window.LibratoMetrics = { feature_flags: {} }
var context = require.context('./', true, /spec\.coffee$/);
context.keys().forEach(context);
