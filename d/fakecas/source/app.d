import std.file;
import std.format;
import std.path;

import inifiled;
import vibe.d;

@INI("Server Configuration")
struct ServerConfig {
    @INI("The port to listen on")
    ushort port = 8080;
}

// abandoned because the rest interface is wrapping the output
interface IFakeCAS {
    /**
     * Checks the validity of a service ticket and returns an XML-fragment response.
     * /serviceValidate MUST also generate and issue proxy-granting tickets when requested.
     * /serviceValidate MUST NOT return a successful authentication if it receives a proxy ticket.
     * It is RECOMMENDED that if /serviceValidate receives a proxy ticket, the error message in the XML response SHOULD explain that validation failed because a proxy ticket was passed to /serviceValidate.
     * 
     * Error Codes
     *      INVALID_REQUEST - not all of the required request parameters were present
     *      INVALID_TICKET_SPEC - failure to meet the requirements of validation specification
     *      UNAUTHORIZED_SERVICE_PROXY - the service is not authorized to perform proxy authentication
     *      INVALID_PROXY_CALLBACK - The proxy callback specified is invalid. The credentials specified for proxy authentication do not meet the security requirements
     *      INVALID_TICKET - the ticket provided was not valid, or the ticket did not come from an initial login and renew was set on validation. The body of the \<cas:authenticationFailure\> block of the XML response SHOULD describe the exact details.
     *      INVALID_SERVICE - the ticket provided was valid, but the service specified did not match the service associated with the ticket. CAS MUST invalidate the ticket and disallow future validation of that same ticket.
     *      INTERNAL_ERROR - an internal error occurred during ticket validation
     * 
     * Params:
     *      service = [REQUIRED] - the identifier of the service for which the ticket was issued.
     *                  As a HTTP request parameter, the service value MUST be URL-encoded.
     *      ticket = [REQUIRED] - the service ticket issued by /login.
     *      pgtUrl = [OPTIONAL] - the URL of the proxy callback.
     *                  As a HTTP request parameter, the “pgtUrl” value MUST be URL-encoded.
     *      renew = [OPTIONAL] - if this parameter is set, ticket validation will only succeed if the service ticket was issued from the presentation of the user’s primary credentials.
     *                  It will fail if the ticket was issued from a single sign-on session.
     * 
     * Returns:
     *      On ticket validation success:
     *          <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
     *              <cas:authenticationSuccess>
     *                  <cas:user>username</cas:user>
     *                  <cas:proxyGrantingTicket>PGTIOU-84678-8a9d...</cas:proxyGrantingTicket>
     *                  <cas:proxies>
     *                      <cas:proxy>https://proxy2/pgtUrl</cas:proxy>
     *                      <cas:proxy>https://proxy1/pgtUrl</cas:proxy>
     *                  </cas:proxies>
     *               </cas:authenticationSuccess>
     *          </cas:serviceResponse>
     * 
     *      On ticket validation failure:
     *          <cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas">
     *               <cas:authenticationFailure code="INVALID_TICKET">
     *                   Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized`
     *               </cas:authenticationFailure>
     *          </cas:serviceResponse>
     * 
     * Examples:
     * ----------------------------------------------------------------------------
     * https://cas.example.org/cas/serviceValidate?service=http%3A%2F%2Fwww.example.org%2Fservice&ticket=ST-1856339-aA5Yuvrxzpv8Tau1cYQ7
     * https://cas.example.org/cas/serviceValidate?service=http%3A%2F%2Fwww.example.org%2Fservice&ticket=ST-1856339-aA5Yuvrxzpv8Tau1cYQ7&renew=true
     * https://cas.example.org/cas/serviceValidate?service=http%3A%2F%2Fwww.example.org%2Fservice&ticket=ST-1856339-aA5Yuvrxzpv8Tau1cYQ7&pgtUrl=https://www.example.org%2Fservice%2FproxyCallback
     * ----------------------------------------------------------------------------
     * 
     * See_Also:
     *      http://jasig.github.io/cas/development/protocol/CAS-Protocol-Specification.html#head2.5
     *      http://jasig.github.io/cas/development/protocol/CAS-Protocol-Specification.html#proxyvalidate-cas-20
     */
    @path("/cas/proxyValidate")
    string getProxyValidate(string service, string ticket, string pgtUrl=null, bool renew=false);

    /// ditto
    @path("/cas/serviceValidate")
    string getServiceValidate(string service, string ticket, string pgtUrl=null, bool renew=false);

    /**
     * /validate checks the validity of a service ticket. /validate is part of the CAS 1.0 protocol and thus does not handle proxy authentication.
     * CAS MUST respond with a ticket validation failure response when a proxy ticket is passed to /validate.
     * 
     * Params:
     *      service = [REQUIRED] - the identifier of the service for which the ticket was issued.
     *                  As a HTTP request parameter, the service value MUST be URL-encoded.
     *      ticket = [REQUIRED] - the service ticket issued by /login.
     *      renew = [OPTIONAL] - if this parameter is set, ticket validation will only succeed if the service ticket was issued from the presentation of the user’s primary credentials.
     *                  It will fail if the ticket was issued from a single sign-on session.
     * 
     * Returns:
     *      success = yes\n
     *      failure = no\n
     * 
     * Examples:
     * ----------------------------------------------------------------------------
     * https://cas.example.org/cas/validate?service=http%3A%2F%2Fwww.example.org%2Fservice&ticket=ST-1856339-aA5Yuvrxzpv8Tau1cYQ7
     * https://cas.example.org/cas/validate?service=http%3A%2F%2Fwww.example.org%2Fservice&ticket=ST-1856339-aA5Yuvrxzpv8Tau1cYQ7&renew=true
     * ----------------------------------------------------------------------------
     * 
     * See_Also:
     *      http://jasig.github.io/cas/development/protocol/CAS-Protocol-Specification.html#validate-cas-10
     */
    //@path("/validate")
    string getValidate(string service, string ticket, bool renew=false);
}

class FakeCASImpl : IFakeCAS {
    string getProxyValidate(string service, string ticket, string pgtUrl, bool renew) {
        return ticket;
    }

    string getServiceValidate(string service, string ticket, string pgtUrl, bool renew) {
        return getProxyValidate(service, ticket, pgtUrl, renew);
    }

    string getValidate(string service, string ticket, bool renew) {
        return "yes\n";
    }
}

void errorPage(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error) {
    res.render!("error.dt", req, error);
}

// also serviceValidate
void proxyValidate(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP("service" in req.query, HTTPStatus.badRequest, "Required field missing: service");
    enforceHTTP("ticket" in req.query, HTTPStatus.badRequest, "Required field missing: ticket");

    string content = format(`<cas:serviceResponse xmlns:cas="http://www.yale.edu/tp/cas"><cas:authenticationSuccess><cas:user>%1$s</cas:user><cas:proxyGrantingTicket>%1$s</cas:proxyGrantingTicket></cas:authenticationSuccess></cas:serviceResponse>`, req.query["ticket"]);
    res.writeBody(content, "application/xml");
}

// also serviceValidate
void validate(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP("service" in req.query, HTTPStatus.badRequest, "Required field missing: service");
    enforceHTTP("ticket" in req.query, HTTPStatus.badRequest, "Required field missing: ticket");

    res.writeBody(format("yes\n%s\n", req.query["ticket"]));
}

shared static this() {
    ServerConfig properties;
    auto configFile = buildPath("config", "server.ini");
    if (configFile.exists) {
        readINIFile(properties, configFile);
    } else {
        if (!exists("config")) {
            mkdirRecurse("config");
        }
        writeINIFile(properties, configFile);
    }

    auto settings = new HTTPServerSettings;
    settings.port = properties.port;
    settings.errorPageHandler = toDelegate(&errorPage);

    auto router = new URLRouter;

    router.get("/cas/proxyValidate", &proxyValidate);
    router.get("/cas/serviceValidate", &proxyValidate);
    router.get("/validate", &validate);
    //router.registerRestInterface(new FakeCASImpl);

    router.get("*", serveStaticFiles("public"));

    listenHTTP(settings, router);

    logInfo("Open your browser to localhost:%s", properties.port);
}
