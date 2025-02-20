# ocaml_chat

## Pre-requisites
1. opam (~>2.3.0)
2. ocaml
    
## Usage
[Highly Recommended] create a switch after cloning and entering the project dir.
`opam switch create . 5.3.0`

Install the necessary dependencies
`opam install . --deps-only`

Build project
`dune clean && dune build`

Start the server
`dune exec chatroom -- -s --port <port>`

Without flags (server listens at port `12345`)
`dune exec chatroom -- -s`

Start the client
`dune exec chatroom -- -c --host <hostname/ip> --port <port>`

Without flags (`host`=127.0.0.1 `port`=12345)
`dune exec chatroom -- -c`

## Specsheet
1. Server can establish connections with multiple clients but only one client can send and receive messages to/from the server.
