open Printf
let (let*) = Lwt.bind

(* Start the client, connect to the server, and start message handling *)
let start_client server_ip port =
  let socket = Lwt_unix.socket PF_INET SOCK_STREAM 0 in
  let server_addr = Unix.ADDR_INET (Unix.inet_addr_of_string server_ip, port) in
  let* () = Lwt_unix.connect socket server_addr in
  printf "Connected to server at %s:%d\n" server_ip port;
  flush stdout;
  Lwt.pick [Input.handle_stdin socket; Wireprotocol.read_message socket]
