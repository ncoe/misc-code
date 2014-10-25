module server.config;

import inifiled;

@INI("Server Configuration")
struct ServerConfig {
    @INI("The port to listen on")
    ushort port = 8080;
}
