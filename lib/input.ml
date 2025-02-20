let (let*) = Lwt.bind

(** Command to send message *)
let send_command = "/send"

(** Accumulate lines until send command *)
let rec read_multiline acc =
  let* line = Lwt_io.(read_line_opt stdin) in
  match line with
  | Some line ->
    if line = send_command then
      Lwt.return (String.concat "\n" (List.rev acc))
    else
      read_multiline (line :: acc)
  | None ->
    Lwt.return (String.concat "\n" (List.rev acc))

(** Read from stdin loop*)
let rec handle_stdin_loop socket =
  let* message = read_multiline [] in
  if String.trim message <> "" then
    let* _ = Wireprotocol.send_message socket message in
    handle_stdin_loop socket
  else
    handle_stdin_loop socket

(** Initialize stdin handling *)
let handle_stdin socket =
  Printf.printf "Enter your message (type '/send' on a new line to send):\n%!";
  handle_stdin_loop socket
