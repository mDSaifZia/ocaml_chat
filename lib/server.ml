open Lwt.Infix
open Printf

let (let*) = Lwt.bind

(** handles communication with a connected client *)
let handle_client socket =
  let rec communication_loop () =
    Lwt.catch
      (fun () ->
         Lwt.pick [
           Input.handle_stdin socket;
           Wireprotocol.read_message socket
         ] >>= fun () ->
         communication_loop ())
      (function
        | End_of_file ->
          printf "Client disconnected\n";
          flush stdout;
          Lwt_unix.close socket
        | e ->
          printf "Error handling client: %s\n" (Printexc.to_string e);
          flush stdout;
          Lwt_unix.close socket)
  in
  communication_loop ()

(** accepts incoming client connections and calls
    client handler function *)
let rec accept_connections server_socket =
  let* (client_socket, _) = Lwt_unix.accept server_socket in
  let* () = handle_client client_socket in
  accept_connections server_socket

(** initializes the server socket and starts accepting connections *)
let start_server port =
  let sockaddr = Unix.(ADDR_INET (inet_addr_any, port)) in
  let server_socket = Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in

  Lwt_unix.setsockopt server_socket Unix.SO_REUSEADDR true;
  let* () = Lwt_unix.bind server_socket sockaddr in
  Lwt_unix.listen server_socket 10;

  printf "Server listening on port %d\n" port;
  flush stdout;
  accept_connections server_socket
