(** message type variants *)
type message_type =
  | Data
  | Ack

(** sends a message over the given socket *)

val send_message : Lwt_unix.file_descr -> string -> unit Lwt.t

(** reads messages from the socket,
    handling both data messages and acknowledgments. *)
val read_message : Lwt_unix.file_descr -> unit Lwt.t
