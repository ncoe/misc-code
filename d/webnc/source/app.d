module app;

import std.datetime : Clock, DateTime;
import std.file;
import std.functional;
import std.path;
import std.stdio : File;
import std.string : format;

import inifiled;

import vibe.core.log;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;
import vibe.web.web;

import server.config;
import webapp.comics.service;
import webapp.twitch.service;

shared static this() {
    // TODO: Log rotation does not come in vanilla vibe, consider adding one
//    DateTime today = cast(DateTime)Clock.currTime();
//    string logName = format("webnc_%04d%02d%02d.html", today.year, cast(int)today.month, today.day);

    // File infoFile = File("webnc.log", "ab");
    // File diagFile = File(logName, "ab");
    // auto fileLogger = cast(shared)new FileLogger(infoFile, diagFile);
    // {
        // fileLogger.minLevel = LogLevel.debug_;
    // }
    // fileLogger.registerLogger();

    auto logName = "webnc.html";
    if (logName.exists) {
        logName.remove();
    }
    auto logger = cast(shared)new HTMLLogger(logName);
    registerLogger(logger);

    logInfo("------------------------------------------------------------------------------------");
    logInfo("-----------------------        Starting webapps...         -----------------------");
    logInfo("------------------------------------------------------------------------------------");

    ServerConfig properties;
    auto configFile = buildPath("config","server.ini");
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

    router.get("/", &homePage);

    WebInterfaceSettings wis = new WebInterfaceSettings();
    wis.urlPrefix = "/comics";
    router.registerWebInterface(new ComicsService(), wis);

    wis = new WebInterfaceSettings();
    wis.urlPrefix = "/twitch";
    router.registerWebInterface(new TwitchService(), wis);

    router.get("*", serveStaticFiles("public"));

    listenHTTP(settings, router);

    logInfo("Open your browser to localhost:%s", properties.port);
}

void errorPage(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error) {
    res.render!("error.dt", req, error);
}

void homePage(HTTPServerRequest req, HTTPServerResponse res) {
    res.render!("index.dt");
}
