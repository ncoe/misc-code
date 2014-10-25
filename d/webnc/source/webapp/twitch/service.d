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
            properties.initDefault();
            writeINIFile(properties, configFile);
        }

        logDiagnostic("Initializing the twitch service");
    }

    @path("/twitch/live")
    void getLive(HTTPServerRequest req, HTTPServerResponse res) {
        LiveData[] liveStreams;

        foreach (name; properties.following) {
            string uri = baseStreamUri ~ name;
            logDebug("URI %s", uri);

            requestHTTP(uri,
                (scope req) {
                    req.method = HTTPMethod.GET;
                },
                (scope res) {
                    if (res.statusCode < 300) {
                        auto response = res.readJson();
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
            );
        }

        res.render!("live.dt", liveStreams);
    }

    @path("/twitch/link")
    void postLink(HTTPServerRequest req, HTTPServerResponse res) {
        auto builder = appender!string();
        builder.put("http://www.multitwitch.tv");

        foreach(param; req.form) {
            logDebug("Streamer chosen: %s", param);

            builder.put("/");
            builder.put(param);
        }
        logDebug("Redirecting to: %s", builder.data);

        res.redirect(builder.data);
    }
}
