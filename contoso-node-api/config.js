const config = {
    mongodbConnection: process.env.COSMOS_MONGO_CONNECTION_STRING,
    dbName: process.env.COSMOS_MONGO_DATABASE_NAME,
    connectionString: process.env.ACS_CONNECTION_STRING,
    jwtPrivateKey: process.env.API_JWT_PRIVATE_KEY,
    endpoint: process.env.ACS_ENDPOINT,
    smsLogicAppEndpoint: process.env.SMS_LOGIC_APP_ENDPOINT,
    qnaMakerEndpoint: process.env.QNA_MAKER_ENDPOINT,
    qnaMakerEndpointKey: process.env. QNA_MAKER_KEY
};

module.exports = config;