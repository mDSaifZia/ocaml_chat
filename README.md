# ocaml_chat

## Pre-requisites
1. opam
2. ocaml
    
## Usage
[Highly Recommended] create a switch after cloning and entering the project dir - 
`opam switch create . 5.3.0`

Install the necessary dependencies - 
`opam install . --deps-only`

Build project - 
`dune clean && dune build`

Start the server -
`dune exec chatroom -- -s --port <port>`

Without flags (server listens at port `12345`) -
`dune exec chatroom -- -s`

Start the client - 
`dune exec chatroom -- -c --host <hostname/ip> --port <port>`

Without flags (`host`=127.0.0.1 `port`=12345) - 
`dune exec chatroom -- -c`

### How to send messages -
After starting the applicaiton in both client and server mode in different terminal sessions. Type your message out.
Once done, send the message by typing '/send' on a newline and clicking `Enter`. Example:-
```
Hi this is a message example
/send
```
## Specsheet
### One on One chat
1. Server can establish connections with multiple clients but only one client can send and receive messages to/from the server.
### WireProtocol
2. Every message type (data or acknowledgement) has header bytes.
   A message has 9 byte header (1 byte for msg_type, 4 bytes for seq ID, 4 bytes for content length).
   An acknowledgement has 5 byte header (1 byte for msg_type, 4 byte for seq ID of message being acknowledged).
3. RTT for each message is displayed.
