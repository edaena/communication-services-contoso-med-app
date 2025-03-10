const bycript = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require("../config");
const userService = require('../services/user.service');
const { CommunicationIdentityClient } = require('@azure/communication-administration')
const dbClient = require('../db/index')

const login = async (req, res) => {

    // get email and password from POST body
    const { email, password } = req.body;

    // find existing user
    var userIdentity = await userService.getUser(email, password)

    if (userIdentity) {
        var token = jwt.sign({ email: email, userType: 'Patient' }, config.jwtPrivateKey, { expiresIn: '1h' });
        
        let tokenResponse = await getTokenResponse(userIdentity)

        // update the users list
        await userService.updateSpoolID(tokenResponse.user.communicationUserId, tokenResponse.token, email)
        res.status(200).json({
            email: email,
            token: token,
            name: userIdentity.name,
            spoolID: tokenResponse.user.communicationUserId,
            spoolToken: tokenResponse.token,
            userType: 'Patient'
        });
    }
    else {
        res.status(401).json({ message: "Invalid User "});
    }
}

const doctorLogin = async (req, res) => {
    // get email and password from POST body
    const { email, password } = req.body;    

    // find existing user    
    var userIdentity = await userService.getDoctor(email, password)

    if (userIdentity) {
        var token = jwt.sign({ email: email, userType: 'Doctor' }, config.jwtPrivateKey, { expiresIn: '1h' });
        
        let tokenResponse = await getTokenResponse(userIdentity)

        // update the users list
        await userService.updateSpoolIDForDoctor(tokenResponse.user.communicationUserId, tokenResponse.token, email)
        res.status(200).json({
            email: email,
            token: token,
            name: 'Dr. ' + userIdentity.name,
            spoolID: tokenResponse.user.communicationUserId,
            spoolToken: tokenResponse.token,
            userType: 'Doctor'
        });
    }
    else {
        res.status(401).json({ message: "Invalid User "});
    }
}

const getTokenResponse = async (userIdentity) => {
    // generate the spool id and token
    const identityClient = new CommunicationIdentityClient(config.connectionString)
    let tokenResponse = undefined;
    if (userIdentity && userIdentity.spoolID) {
        console.log("just updating token as user already exists...");
        tokenResponse = await identityClient.issueToken({ communicationUserId: userIdentity.spoolID }, ["voip", "chat"])
    }
    else {
        let userResponse = await identityClient.createUser();
        tokenResponse = await identityClient.issueToken(userResponse, ["voip", "chat"]);
    }
    console.log(tokenResponse)
    return tokenResponse
}

exports.login = login;
exports.doctorLogin = doctorLogin;
