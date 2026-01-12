importScripts("sql-wasm.js");

var db;

self.addEventListener('message', function(e) {
  var data = e.data;
  switch (data.method) {
    case 'init':
      initSqlJs({
        locateFile: file => `./${file}`
      }).then(function(SQL){
        db = new SQL.Database();
        self.postMessage({id: data.id, result: true});
      });
      break;
    case 'execute':
      try {
        db.run(data.sql);
        self.postMessage({id: data.id, result: true});
      } catch (err) {
        self.postMessage({id: data.id, error: err.toString()});
      }
      break;
    case 'query':
      try {
        var result = db.exec(data.sql);
        self.postMessage({id: data.id, result: result});
      } catch (err) {
        self.postMessage({id: data.id, error: err.toString()});
      }
      break;
  }
});
