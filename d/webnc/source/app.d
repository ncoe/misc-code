import std.file;

import inifiled;
import vibe.d;

import server.config;
import webapp.comics.service;
import webapp.twitch.service;

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
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;

    router.get("/", &homePage);

    WebInterfaceSettings wis = new WebInterfaceSettings();
    wis.urlPrefix = "/comics";
    router.registerWebInterface(new ComicsService(), wis);

    wis = new WebInterfaceSettings();
    wis.urlPrefix = "/twitch";
    router.registerWebInterface(new TwitchService(), wis);

    router.get("*", serveStaticFiles("public"));
    listenHTTP(settings, router);

    logInfo("Please open http://127.0.0.1:%s/ in your browser.", properties.port);
}

void homePage(HTTPServerRequest req, HTTPServerResponse res) {
    res.render!("index.dt");
}
