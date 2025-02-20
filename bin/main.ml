open Chatroom

let usage_msg = "Usage: chatroom [-c | -s] [--host host] [--port port]"

let is_client = ref false
let is_server = ref false
let host = ref "127.0.0.1"
let port = ref 12345

let spec_list = [
  ("-c", Arg.Set is_client, "Run as client");
  ("-s", Arg.Set is_server, "Run as server");
  ("--host", Arg.Set_string host, "Host address"); (* for client only*)
  ("--port", Arg.Set_int port, "Port number");
]

(** all arguments must be preceded by "--" *)
let handle_anonymous_arg arg =
  Printf.printf "Error: Unexpected argument '%s'\n" arg;
  Printf.printf "%s\n" usage_msg;
  exit 1

let () =
  try
    Arg.parse spec_list handle_anonymous_arg usage_msg;

    if !is_client && !is_server then begin
      Printf.printf "Error: Cannot run as both client and server\n";
      exit 1
    end;

    if not (!is_client || !is_server) then begin
      Printf.printf "Error: Must specify either -c (client) or -s (server)\n";
      Printf.printf "%s\n" usage_msg;
      exit 1
    end;

    if !is_server then
      Lwt_main.run (Server.start_server !port)
    else
      Lwt_main.run (Client.start_client !host !port)
  with
  | Arg.Bad msg ->
    Printf.printf "Error: %s\n" msg;
    Printf.printf "%s\n" usage_msg;
    exit 1
  | Arg.Help msg ->
    Printf.printf "%s\n" msg;
    exit 0
