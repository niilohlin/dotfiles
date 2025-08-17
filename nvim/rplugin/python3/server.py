from pynvim import plugin, command, Nvim  # type: ignore
import markdown

from http.server import BaseHTTPRequestHandler, HTTPServer
import logging

logging.basicConfig(filename="/tmp/vaultserver.log", level=logging.DEBUG)
logger = logging.getLogger(__name__)


class PathHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            f = open("Permanent Notes/Home.md")
            s = f.read()
            f.close()
            self.wfile.write(markdown.markdown(s).encode("utf-8"))
        else:
            self.send_response(404)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(b"<h1>404 - Page Not Found</h1>")


@plugin
class Server:
    def __init__(self, nvim: Nvim):
        self.nvim = nvim

    @command("StartVaultServer", nargs="*", range="")
    def start_vault(self, args: list[str], rng):
        path = "/Users/niilohlin/Vault/"
        self.nvim.chdir(path)
        server = HTTPServer(("localhost", 8000), PathHandler)
        self.nvim.out_write("Starting server")
        logger.debug("starting server")
        server.serve_forever()
        self.nvim.out_write("Server running at http://localhost:8000\n")
        logger.debug("starting server")


if __name__ == "__main__":
    import os

    os.chdir("/Users/niilohlin/Vault/")
    server = HTTPServer(("localhost", 8000), PathHandler)
    server.serve_forever()
