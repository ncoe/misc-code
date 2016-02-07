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

            auto streamField = jsonObj.stream;
            if (Json.Type.object == streamField.type) {
                auto gameField = streamField.game;

                string game = "<UNKNOWN>";
                if (Json.Type.string == gameField.type) {
                    game = streamField.game.get!string;
                }

                string title = "<UNKNOWN>";
                auto channelField = streamField.channel;
                if (Json.Type.object == channelField.type) {
                    auto statusField = channelField.status;
                    if (Json.Type.string == statusField.type) {
                        title = statusField.get!string;
                    }
                }

                string preview = null;
                auto previewField = streamField.preview;
                if (Json.Type.object == previewField.type) {
                    auto smallField = previewField.small;
                    auto mediumField = previewField.medium;
                    auto largeField = previewField.large;
                    if (Json.Type.string == mediumField.type) {
                        preview = mediumField.get!string;
                    } else if (Json.Type.string == largeField.type) {
                        preview = largeField.get!string;
                    } else if (Json.Type.string == smallField.type) {
                        preview = smallField.get!string;
                    }
                }

                int viewers = 0;
                auto viewersField = streamField.viewers;
                if (Json.Type.int_ == viewersField.type) {
                    viewers = viewersField.get!int;
                }

                return new LiveData(name, game, title, preview, viewers);
            }
        }
    }

    httpResponse.disconnect;
    return null;
}

