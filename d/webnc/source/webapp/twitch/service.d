module webapp.twitch.service;

import std.algorithm : sort;
import std.file;
import std.path;

import inifiled;
import vibe.core.log;
import vibe.data.json;
import vibe.http.client;
import vibe.http.server;

import webapp.twitch.config;

class LiveData {
    string name;
    string game;
    string title;
    string preview;
    int viewers;

    this(string name, string game, string title, string preview, int viewers) {
        this.name = name;
        this.game = game;
        this.title = title;
        this.preview = preview;
        this.viewers = viewers;
    }
}

class TwitchService {
    private {
        TwitchConfig properties;
    }

    this() {
        auto configFile = buildPath("config", "twitch.ini");

        if (configFile.exists) {
            readINIFile(properties, configFile);
        } else {
            if (!exists("config")) {
                mkdirRecurse("config");
            }
            properties.initDefault();
            writeINIFile(properties, configFile);
        }

        logTrace("The Twitch properties are: %s", properties);
        logDiagnostic("Initializing the twitch service");
    }

    void getLive(HTTPServerRequest req, HTTPServerResponse res) {
        LiveData[] liveList;
        foreach (name; properties.following) {
            auto response = checkStream(name);
            if (response !is null) {
                liveList ~= response;
            }
        }

        auto liveStreams = sort!("a.viewers > b.viewers")(liveList);

        res.headers.addField("Cache-Control", "no-cache, no-store, must-revalidate");
        res.headers.addField("Pragma", "no-cache");
        res.headers.addField("Expires", "0");
        res.render!("live.dt", liveStreams);
    }

    void postLink(HTTPServerRequest req, HTTPServerResponse res) {
        auto builder = appender!string();
        auto streamers = req.form.getAll("streamer");
        logInfo("#streamers=%d", streamers.length);

        if (streamers.length > 1) {
            if (req.form["site"] == "multitwitch") {
                builder.put("http://www.multitwitch.tv");
            } else {
                builder.put("http://www.kadgar.net/live");
            }
        } else {
            builder.put("http://www.twitch.tv");
        }

        if (auto all = req.form.get("option.all")) {
            builder.put(all);
        } else {
            foreach(param; streamers) {
                logDebug("Streamer chosen: %s", param);

                builder.put("/");
                builder.put(param);
            }
        }

        if (req.form.get("hls")) {
            builder.put("/hls");
            // http://www.twitch.tv/morvelaira/chat?popout=
        }

        logDebug("Redirecting to: %s", builder.data);
        res.redirect(builder.data);
    }
}

static immutable baseStreamUri = "https://api.twitch.tv/kraken/streams/";

LiveData checkStream(string name) {
    HTTPClientResponse httpResponse;
    bool success = false;

    string uri = baseStreamUri ~ name;
    for (int tries=0; tries<3; ++tries) {
        try {
            httpResponse = requestHTTP(uri,
                (scope request) {
                    request.headers.addField("Accept", "application/vnd.twitchtv.v3+json");
                }
            );
            success = true;
            logDebug("Found data about: %s", name);
            break;
        } catch(Exception e) {
            logWarn("Experienced an issue trying to discover the status of %s: (%s@%s): %s", name, e.file, e.line, e.msg);
        }
    }

    if (httpResponse.statusCode >= 400) {
        logError("Bad response: %s", httpResponse.toString);
    } else {
        auto jsonObj = httpResponse.readJson;
        if (Json.Type.null_ != jsonObj.stream.type) {
            logTrace("Raw data: %s", jsonObj);

            string game = jsonObj.stream.game.get!string;
            string title = jsonObj.stream.channel.status.get!string;
            string preview = jsonObj.stream.preview.medium.get!string;
            int viewers = jsonObj.stream.viewers.get!int;

            return new LiveData(name, game, title, preview, viewers);
        }
    }

    httpResponse.disconnect;

    return null;
}

