if (process.env.MYSQL_HOST || process.env.CONNECTION_MYSQLDB_PROPERTIES) module.exports = require('./mysql');
else module.exports = require('./sqlite');
