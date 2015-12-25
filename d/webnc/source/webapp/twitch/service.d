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

        bool edge;
        if (auto value = req.headers["User-Agent"]) {
            import std.regex;
            auto r = regex(`\bEdge/`);
            edge = !value.matchFirst(r).empty;
        }

        foreach (name; properties.following) {
            string uri = baseStreamUri ~ name;
            logDebug("URI %s", uri);

            bool success = false;
            HTTPClientResponse httpResponse;
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

            if (!success) {
                logError("Failed to discover the status of %s, assuming they are not streaming.", name);
            } else {
                if (httpResponse.statusCode < 300) {
                    auto response = httpResponse.readJson();
                    logDebug("The json body is: %s", response);

                    logTrace("%s", response.toPrettyString);
                    if (Json.Type.object == response.type) {
                        auto stream = response["stream"];
                        if (Json.Type.null_ != stream.type) {
                            // logInfo("%s is currently live", name);

                            auto game = stream["game"];
                            if (Json.Type.string != game.type) {
                                game = "<UNKNOWN GAME>";
                            }

                            auto preview = stream["preview"];
                            auto channel = stream["channel"];

                            auto title = channel["status"];
                            if (Json.Type.string != title.type) {
                                title = "<UNKNOWN TITLE>";
                            }

                            logDebug("%s is playing %s entitled %s\n",
                                     name,
                                     game,
                                     title);
                            rawStreams ~= LiveData(name,
                                                   game.get!string,
                                                   title.get!string,
                                                   preview["small"].get!string,
                                                   stream["viewers"].get!int);
                        } else {
                            logInfo("%s is offline", name);
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
        res.render!("live.dt", liveStreams, edge);
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

    @path("/linkImmediate/:name")
    void postLinkImmediate(HTTPServerRequest req, HTTPServerResponse res, string _name) {
        auto builder = appender!string();

        builder.put("http://www.twitch.tv/");
        builder.put(_name);

        if (req.form.get("hls")) {
            builder.put("/hls");
            // http://www.twitch.tv/morvelaira/chat?popout=
        }

        logDebug("Redirecting to: %s", builder.data);
        res.redirect(builder.data);
    }
}
