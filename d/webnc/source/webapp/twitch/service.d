module webapp.twitch.service;

import std.algorithm : sort;
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
    string preview;
    int viewers;
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

    void getLive(HTTPServerRequest req, HTTPServerResponse res) {
        LiveData[] rawStreams;

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

                    logDebug("%s", response.toPrettyString);
                    if (Json.Type.object == response.type) {
                        auto stream = response["stream"];
                        if (Json.Type.object != stream.type) {
                            logDebug("%s is NOT Streaming\n", name);
                        } else {
                            auto game = stream["game"];
                            if (Json.Type.string != game.type) {
                                game = "<UNKNOWN GAME>";
                            }

                            string title;
                            auto channel = stream["channel"];
                            if (Json.Type.object == channel.type) {
                                auto status = channel["status"];
                                if (Json.Type.string != status.type) {
                                    title = "<UNTITLED>";
                                } else {
                                    title = status.get!string; // Why would they put this in status?????
                                }
                            }

                            string medium;
                            auto preview = stream["preview"];
                            if (Json.Type.object == preview.type) {
                                auto mediumJson = preview["medium"];
                                medium = mediumJson.get!string;
                            }

                            auto viewers = stream["viewers"];

                            logDebug("%s is playing %s entitled %s\n", name, game, title);
                            rawStreams ~= LiveData(name, game.get!string, title, medium, viewers.get!int);
                        }
                    } else {
                        logInfo("Cannot determine status of %s\n", name);
                    }
                } else {
                    logWarn("Could not find out information about %s", name);
                }
            }
        }

        auto liveStreams = sort!("a.viewers > b.viewers")(rawStreams);

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

        logDebug("Redirecting to: %s", builder.data);
        res.redirect(builder.data);
    }
}
