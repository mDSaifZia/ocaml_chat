open Printf

let (let*) = Lwt.bind

(** message types *)
type message_type =
  | Data
  | Ack

(** convert message type to byte *)
let message_type_to_byte = function
  | Data -> Char.chr 0
  | Ack -> Char.chr 1

(** convert byte to message type *)
let byte_to_message_type byte = match Char.code byte with
  | 0 -> Data
  | 1 -> Ack
  | n -> failwith (Printf.sprintf "Invalid message type: %d" n)

(** hash table to keep track of messages pending acknowledgement *)
let pending_ack : (int, float) Hashtbl.t = Hashtbl.create 256

(** sequence number generator *)
let next_seq = ref 0
let get_next_seq () =
  let seq = !next_seq in
  incr next_seq;
  seq


(** read exactly n bytes from socket *)
let rec read_exact socket buf offset length =
  let%lwt received = Lwt_unix.recv socket buf offset length [] in
  if received = 0 then
    Lwt.fail_with "Connection closed by peer"
  else if received < length then
    read_exact socket buf (offset + received) (length - received)
  else
    Lwt.return_unit

(** send acknowledgement for a message *)
let send_ack socket seq_bytes =
  let packet = Bytes.create 5 in
  Bytes.set packet 0 (message_type_to_byte Ack);
  Bytes.blit seq_bytes 0 packet 1 4;
  let* _ = Lwt_unix.write socket packet 0 5 in
  Lwt.return_unit

(** send a message with automatic sequence numbering *)
let send_message socket message =
  if String.length (String.trim message) = 0 then (*ignore empty strings*)
    Lwt.return_unit
  else
    let start_time = Unix.gettimeofday () in
    let seq = get_next_seq () in
    Hashtbl.add pending_ack seq start_time;
    printf "Sending message %d: %s\n" seq message;
    flush stdout;
    let message_length = String.length message in
    let packet = Bytes.create (1 + 4 + 4 + message_length) in
    Bytes.set packet 0 (message_type_to_byte Data);
    Bytes.set_int32_be packet 1 (Int32.of_int seq);
    Bytes.set_int32_be packet 5 (Int32.of_int message_length);
    Bytes.blit_string message 0 packet 9 message_length;
    let* _ = Lwt_unix.write socket packet 0 (Bytes.length packet) in
    Lwt.return_unit

(** handle acknowledgement receipt *)
let handle_ack seq =
  match Hashtbl.find_opt pending_ack seq with
  | Some start_time ->
    let rtt = Unix.gettimeofday () -. start_time in
    Printf.printf "Message %d acknowledged, RTT: %f seconds\n" seq rtt;
    flush stdout;
    Hashtbl.remove pending_ack seq;
    Lwt.return_unit
  | None ->
    Printf.printf "Received ack for unknown message %d\n" seq;
    flush stdout;
    Lwt.return_unit

(** socket message reading and handling function *)
let rec read_message socket =
  Lwt.catch
    (fun () ->
       let msg_type_buf = Bytes.create 1 in
       let%lwt () = read_exact socket msg_type_buf 0 1 in
       match byte_to_message_type (Bytes.get msg_type_buf 0) with
       | Ack ->
         let seq_buf = Bytes.create 4 in
         let%lwt () = read_exact socket seq_buf 0 4 in
         let seq = Int32.to_int (Bytes.get_int32_be seq_buf 0) in
         let%lwt () = handle_ack seq in
         read_message socket
       | Data ->
         let seq_buf = Bytes.create 4 in
         let%lwt () = read_exact socket seq_buf 0 4 in
         let len_buf = Bytes.create 4 in
         let%lwt () = read_exact socket len_buf 0 4 in
         let msg_len = Int32.to_int (Bytes.get_int32_be len_buf 0) in
         if msg_len = 0 then (* ignore empty message data *)
           read_message socket
         else
           let msg_buf = Bytes.create msg_len in
           let%lwt () = read_exact socket msg_buf 0 msg_len in
           let message = Bytes.to_string msg_buf in
           printf "Received message: %s\n" message;
           flush stdout;
           let%lwt () = send_ack socket seq_buf in
           read_message socket)
    (function
      | End_of_file -> Lwt.fail End_of_file
      | e -> Lwt.fail e)
