module app;

import std.file;
import std.path;

import inifiled;

import vibe.core.log;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.web.web;

import server.config;
import webapp.twitch.service;

shared static this() {
    auto configFile = buildPath("config","server.ini");

    ServerConfig properties;
    if (configFile.exists) {
        readINIFile(properties, configFile);
    } else {
        writeINIFile(properties, configFile);
    }

    auto settings = new HTTPServerSettings;
    settings.port = properties.port;
    // settings.errorPageHandler = toDelegate(&showError);

    auto router = new URLRouter;

    router.get("/", &homePage);
    registerWebInterface(router, new TwitchService());
    router.get("*", serveStaticFiles("public"));

    listenHTTP(settings, router);

    logInfo("Open your browser to localhost:%s", properties.port);
}

void homePage(HTTPServerRequest req, HTTPServerResponse res) {
    res.render!("index.dt");
}
