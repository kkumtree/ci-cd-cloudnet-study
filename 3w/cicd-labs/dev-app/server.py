from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from datetime import datetime
import socket

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        match self.path:
            case '/':
                now = datetime.now()
                hostname = socket.gethostname()
                response_string = now.strftime("The time is %-I:%M:%S %p, VERSION 0.0.2\n")
                response_string += f"Server hostname: {hostname}\n"                
                self.respond_with(200, response_string)
            case '/healthz':
                self.respond_with(200, "Healthy")
            case _:
                self.respond_with(404, "Not Found")

    def respond_with(self, status_code: int, content: str) -> None:
        self.send_response(status_code)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(bytes(content, "utf-8")) 

def startServer():
    try:
        server = ThreadingHTTPServer(('', 80), RequestHandler)
        print("Listening on " + ":".join(map(str, server.server_address)))
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()

if __name__== "__main__":
    startServer()