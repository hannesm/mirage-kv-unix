(*
 * Copyright (c) 2013 Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2014 Hannes Mehnert <hannes@mehnert.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt

type +'a io = 'a Lwt.t
type error =
  | Unknown_key of string
  | Failure of string
type page_aligned_buffer = Cstruct.t

type t = {
  base: string
}

let connect id =
  (* TODO verify base directory exists *)
  return ({ base=id })

let disconnect t =
  return ()

let mem {base} name =
  Fs_common.mem_impl base name >|= function
   | `Error e -> `Error (Failure (Fs_common.string_of_error e))
   | `Ok data -> `Ok data

let read {base} name off len =
  Fs_common.read_impl base name off len >|= function
   | `Error (`No_directory_entry (_, s))-> `Error (Unknown_key s)
   | `Error e -> `Error (Failure (Fs_common.string_of_error e))
   | `Ok data -> `Ok data

let size {base} name =
  Fs_common.size_impl base name >|= function
   | `Error (`No_directory_entry (_, s))-> `Error (Unknown_key s)
   | `Error e -> `Error (Failure (Fs_common.string_of_error e))
   | `Ok data -> `Ok data
