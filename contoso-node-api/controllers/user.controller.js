const userService = require('../services/user.service');
const config = require("../config");

if (!config || !config.connectionString || config.connectionString.indexOf('endpoint=') === -1) {
    throw new Error("Set the 'ACS_CONNECTION_STRING' environment variable");
}