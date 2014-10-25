module webapp.comics.service;

import vibe.http.server;
import vibe.web.common;

import webapp.comics.xkcd;
import webapp.comics.yahoo;

class ComicsService {
    @path("/comics/xkcd")
    void getXKCD(HTTPServerRequest req, HTTPServerResponse res) {
        favoriteXKCD(req, res);
    }

    @path("/comics/yahoo")
    void getYahoo(HTTPServerRequest req, HTTPServerResponse res) {
        yahooComics(req, res);
    }
}
