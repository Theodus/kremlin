(* Copyright (c) INRIA and Microsoft Corporation. All rights reserved. *)
(* Licensed under the Apache 2.0 License. *)

(** All global names must be valid C identifiers and globally-unique... *)

open Warn
open Idents
open Ast
open PrintAst.Ops

type t = (lident, string) Hashtbl.t * (string, unit) Hashtbl.t

let reserve_keywords used_c_names =
  let keywords = [
    "_Alignas";
    "_Alignof";
    "_Atomic";
    "_Bool";
    "_Complex";
    "_Generic";
    "_Imaginary";
    "_Noreturn";
    "_Pragma";
    "_Static_assert";
    "_Thread_local";
    "alignas";
    "alignof";
    "and";
    "and_eq";
    "asm";
    "atomic_cancel";
    "atomic_commit";
    "atomic_noexcept";
    "auto";
    "bitand";
    "bitor";
    "bool";
    "break";
    "case";
    "catch";
    "char";
    "char16_t";
    "char32_t";
    "char8_t";
    "class";
    "co_await";
    "co_return";
    "co_yield";
    "compl";
    "concept";
    "const";
    "const_cast";
    "consteval";
    "constexpr";
    "constinit";
    "continue";
    "decltype";
    "default";
    "delete";
    "do";
    "double";
    "dynamic_cast";
    "else";
    "enum";
    "explicit";
    "export";
    "extern";
    "false";
    "float";
    "for";
    "fortran";
    "friend";
    "goto";
    "if";
    "inline";
    "int";
    "long";
    "mutable";
    "namespace";
    "new";
    "noexcept";
    "not";
    "not_eq";
    "nullptr";
    "operator";
    "or";
    "or_eq";
    "private";
    "protected";
    "public";
    "reflexpr";
    "register";
    "reinterpret_cast";
    "requires";
    "restrict";
    "return";
    "short";
    "signed";
    "sizeof";
    "static";
    "static_assert";
    "static_cast";
    "struct";
    "switch";
    "synchronized";
    "template";
    "this";
    "thread_local";
    "throw";
    "true";
    "try";
    "typedef";
    "typeid";
    "typename";
    "union";
    "unsigned";
    "using";
    "virtual";
    "void";
    "volatile";
    "wchar_t";
    "while";
    "xor";
    "xor_eq";
  ] in
  List.iter (fun k -> Hashtbl.add used_c_names k ()) keywords;
  (* Some stuff that's already almost always in scope. *)
  let std = [
    "errno"
  ] in
  List.iter (fun k -> Hashtbl.add used_c_names k ()) std

let create () =
  let c_of_original = Hashtbl.create 41 in
  let used_c_names: (string, unit) Hashtbl.t = Hashtbl.create 41 in
  reserve_keywords used_c_names;
  c_of_original, used_c_names

let extend (global: t) (local: t) is_local original_name desired_name =
  let c_of_original, g_used_c_names = global in
  let _, l_used_c_names = local in
  if Hashtbl.mem c_of_original original_name then
    fatal_error "Duplicate global name: %a" plid original_name;

  let unique_c_name = mk_fresh desired_name (fun x ->
    Hashtbl.mem g_used_c_names x || Hashtbl.mem l_used_c_names x) in
  Hashtbl.add c_of_original original_name unique_c_name;
  if is_local then
    Hashtbl.add l_used_c_names unique_c_name ()
  else
    Hashtbl.add g_used_c_names unique_c_name ();
  unique_c_name

let lookup (env: t) name =
  let c_of_original, _ = env in
  Hashtbl.find_opt c_of_original name

let clone (env: t) =
  let c_of_original, used_c_names = env in
  Hashtbl.copy c_of_original, Hashtbl.copy used_c_names

let dump (env: t) =
  Hashtbl.iter (fun lident c_name ->
    KPrint.bprintf "%a --> %s\n" plid lident c_name
  ) (fst env);
  Hashtbl.iter (fun c_name _ ->
    KPrint.bprintf "%s is used\n" c_name
  ) (snd env)
