module webapp.twitch.service;

import std.file;
import std.path;

import inifiled;

import vibe.core.log;
import vibe.data.json;
import vibe.http.client;
import vibe.http.server;
import vibe.web.common;

import webapp.twitch.config;

struct LiveData {
    string name;
    string game;
    string title;
}

class TwitchService {
    private {
        static immutable baseStreamUri = "https://api.twitch.tv/kraken/streams/";
        TwitchConfig properties;
    }

    this() {
        auto configFile = buildPath("config","twitch.ini");

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

    @path("/twitch/live")
    void getLive(HTTPServerRequest req, HTTPServerResponse res) {
        LiveData[] liveStreams;

        foreach (name; properties.following) {
            string uri = baseStreamUri ~ name;
            logDebug("URI %s", uri);

            bool success = false;
            HTTPClientResponse httpResponse;
            for (int tries=0; tries<3; ++tries) {
                try {
                    httpResponse = requestHTTP(uri);
                    success = true;
                    break;
                } catch(Exception e) {
                    logWarn("Experienced an issue trying to discover the status of %s: (%s@%s): %s", name, e.file, e.line, e.msg);
                }
            }
            if (!success) {
                logError("Failed to discover the status of %s, assuming they are not streaming.", name);
            } else {
                if (httpResponse.statusCode < 300) {
                    auto response = httpResponse.readJson();
                    logTrace("The json body is: %s", response);

                    auto stream = response["stream"];
                    if (Json.Type.undefined == stream.type || Json.Type.null_ == stream.type) {
                        logDebug("%s is NOT Streaming\n", name);
                    } else {
                        auto channel = stream["channel"];
                        auto game = stream["game"];
                        auto title = channel["status"]; // Why would they put this in status?????

                        if (Json.Type.null_ == game.type) {
                            game = "<UNKNOWN GAME>";
                        }

                        if (Json.Type.null_ == title.type) {
                            title = "<UNTITLED>";
                        }

                        logDebug("%s is playing %s entitled %s\n", name, game, title);
                        liveStreams ~= LiveData(name, game.get!string, title.get!string);
                    }
                } else {
                    logWarn("Could not find out information about %s", name);
                }
            }
        }

        res.render!("live.dt", liveStreams);
    }

    @path("/twitch/link")
    void postLink(HTTPServerRequest req, HTTPServerResponse res) {
        auto builder = appender!string();

        if (req.form["site"] == "multitwitch") {
            builder.put("http://www.multitwitch.tv");
        } else {
            builder.put("http://www.kadgar.net/live");
        }

        if (auto all = req.form.get("option.all")) {
            builder.put(all);
        } else {
            foreach(param; req.form.getAll("streamer")) {
                logDebug("Streamer chosen: %s", param);

                builder.put("/");
                builder.put(param);
            }
        }

        logDebug("Redirecting to: %s", builder.data);
        res.redirect(builder.data);
    }
}
