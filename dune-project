(lang dune 3.17)

(name chatroom)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Mohammad Saif Zia")

(maintainers "Mohammad Saif Zia saifzia.work@gmail.com")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name chatroom)
 (synopsis "Simple one on one chat application")
 (description "A one on one chat system between a server and client communicating via TCP sockets")
 (depends ocaml dune lwt lwt_ppx)
 (tags
  ("tcp" "chatroom" "ocaml")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
