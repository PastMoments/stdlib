//// Strings in Gleam are UTF-8 binaries. They can be written in your code as
//// text surrounded by `"double quotes"`.

import gleam/iterator.{Iterator}
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/order
import gleam/string_builder.{StringBuilder}
@target(erlang)
import gleam/bit_string
@target(erlang)
import gleam/dynamic.{Dynamic}
@target(erlang)
import gleam/result

/// Determines if a `String` is empty.
///
/// ## Examples
///
/// ```gleam
/// > is_empty("")
/// True
/// ```
///
/// ```gleam
/// > is_empty("the world")
/// False
/// ```
///
pub fn is_empty(str: String) -> Bool {
  str == ""
}

/// Gets the number of grapheme clusters in a given `String`.
///
/// This function has to iterate across the whole string to count the number of
/// graphemes, so it runs in linear time.
///
/// ## Examples
///
/// ```gleam
/// > length("Gleam")
/// 5
/// ```
///
/// ```gleam
/// > length("ß↑e̊")
/// 3
/// ```
///
/// ```gleam
/// > length("")
/// 0
/// ```
///
pub fn length(string: String) -> Int {
  do_length(string)
}

@external(erlang, "string", "length")
@external(javascript, "../gleam_stdlib.mjs", "string_length")
fn do_length(a: String) -> Int

/// Reverses a `String`.
///
/// This function has to iterate across the whole `String` so it runs in linear
/// time.
///
/// ## Examples
///
/// ```gleam
/// > reverse("stressed")
/// "desserts"
/// ```
///
pub fn reverse(string: String) -> String {
  do_reverse(string)
}

@target(erlang)
fn do_reverse(string: String) -> String {
  string
  |> string_builder.from_string
  |> string_builder.reverse
  |> string_builder.to_string
}

@target(javascript)
fn do_reverse(string: String) -> String {
  string
  |> to_graphemes
  |> list.reverse
  |> concat
}

/// Creates a new `String` by replacing all occurrences of a given substring.
///
/// ## Examples
///
/// ```gleam
/// > replace("www.example.com", each: ".", with: "-")
/// "www-example-com"
/// ```
///
/// ```gleam
/// > replace("a,b,c,d,e", each: ",", with: "/")
/// "a/b/c/d/e"
/// ```
///
pub fn replace(
  in string: String,
  each pattern: String,
  with substitute: String,
) -> String {
  string
  |> string_builder.from_string
  |> string_builder.replace(each: pattern, with: substitute)
  |> string_builder.to_string
}

/// Creates a new `String` with all the graphemes in the input `String` converted to
/// lowercase.
///
/// Useful for case-insensitive comparisons.
///
/// ## Examples
///
/// ```gleam
/// > lowercase("X-FILES")
/// "x-files"
/// ```
///
pub fn lowercase(string: String) -> String {
  do_lowercase(string)
}

@external(erlang, "string", "lowercase")
@external(javascript, "../gleam_stdlib.mjs", "lowercase")
fn do_lowercase(a: String) -> String

/// Creates a new `String` with all the graphemes in the input `String` converted to
/// uppercase.
///
/// Useful for case-insensitive comparisons and VIRTUAL YELLING.
///
/// ## Examples
///
/// ```gleam
/// > uppercase("skinner")
/// "SKINNER"
/// ```
///
pub fn uppercase(string: String) -> String {
  do_uppercase(string)
}

@external(erlang, "string", "uppercase")
@external(javascript, "../gleam_stdlib.mjs", "uppercase")
fn do_uppercase(a: String) -> String

/// Compares two `String`s to see which is "larger" by comparing their graphemes.
///
/// This does not compare the size or length of the given `String`s.
///
/// ## Examples
///
/// ```gleam
/// > compare("Anthony", "Anthony")
/// order.Eq
/// ```
///
/// ```gleam
/// > compare("A", "B")
/// order.Lt
/// ```
///
pub fn compare(a: String, b: String) -> order.Order {
  case a == b {
    True -> order.Eq
    _ ->
      case less_than(a, b) {
        True -> order.Lt
        _ -> order.Gt
      }
  }
}

@external(erlang, "gleam_stdlib", "less_than")
@external(javascript, "../gleam_stdlib.mjs", "less_than")
fn less_than(a: String, b: String) -> Bool

/// Takes a substring given a start and end grapheme indexes. Negative indexes
/// are taken starting from the *end* of the list.
///
/// ## Examples
///
/// ```gleam
/// > slice(from: "gleam", at_index: 1, length: 2)
/// "le"
/// ```
///
/// ```gleam
/// > slice(from: "gleam", at_index: 1, length: 10)
/// "leam"
/// ```
///
/// ```gleam
/// > slice(from: "gleam", at_index: 10, length: 3)
/// ""
/// ```
///
/// ```gleam
/// > slice(from: "gleam", at_index: -2, length: 2)
/// "am"
/// ```
///
/// ```gleam
/// > slice(from: "gleam", at_index: -12, length: 2)
/// ""
/// ```
///
pub fn slice(from string: String, at_index idx: Int, length len: Int) -> String {
  case len < 0 {
    True -> ""
    False ->
      case idx < 0 {
        True -> {
          let translated_idx = length(string) + idx
          case translated_idx < 0 {
            True -> ""
            False -> do_slice(string, translated_idx, len)
          }
        }
        False -> do_slice(string, idx, len)
      }
  }
}

@target(erlang)
@external(erlang, "string", "slice")
fn do_slice(a: String, b: Int, c: Int) -> String

@target(javascript)
fn do_slice(string: String, idx: Int, len: Int) -> String {
  string
  |> to_graphemes
  |> list.drop(idx)
  |> list.take(len)
  |> concat
}

/// Drops contents of the first `String` that occur before the second `String`.
/// If the `from` string does not contain the `before` string, `from` is returned unchanged.
///
/// ## Examples
///
/// ```gleam
/// > crop(from: "The Lone Gunmen", before: "Lone")
/// "Lone Gunmen"
/// ```
///
pub fn crop(from string: String, before substring: String) -> String {
  do_crop(string, substring)
}

@target(erlang)
fn do_crop(string: String, substring: String) -> String {
  string
  |> erl_contains(substring)
  |> dynamic.string()
  |> result.unwrap(string)
}

@target(erlang)
@external(erlang, "string", "find")
fn erl_contains(a: String, b: String) -> Dynamic

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "crop_string")
fn do_crop(a: String, b: String) -> String

/// Drops *n* graphemes from the left side of a `String`.
///
/// ## Examples
///
/// ```gleam
/// > drop_left(from: "The Lone Gunmen", up_to: 2)
/// "e Lone Gunmen"
/// ```
///
pub fn drop_left(from string: String, up_to num_graphemes: Int) -> String {
  case num_graphemes < 0 {
    True -> string
    False -> slice(string, num_graphemes, length(string) - num_graphemes)
  }
}

/// Drops *n* graphemes from the right side of a `String`.
///
/// ## Examples
///
/// ```gleam
/// > drop_right(from: "Cigarette Smoking Man", up_to: 2)
/// "Cigarette Smoking M"
/// ```
///
pub fn drop_right(from string: String, up_to num_graphemes: Int) -> String {
  case num_graphemes < 0 {
    True -> string
    False -> slice(string, 0, length(string) - num_graphemes)
  }
}

/// Checks if the first `String` contains the second.
///
/// ## Examples
///
/// ```gleam
/// > contains(does: "theory", contain: "ory")
/// True
/// ```
///
/// ```gleam
/// > contains(does: "theory", contain: "the")
/// True
/// ```
///
/// ```gleam
/// > contains(does: "theory", contain: "THE")
/// False
/// ```
///
pub fn contains(does haystack: String, contain needle: String) -> Bool {
  do_contains(haystack, needle)
}

@target(erlang)
fn do_contains(haystack: String, needle: String) -> Bool {
  haystack
  |> erl_contains(needle)
  |> dynamic.bit_string
  |> result.is_ok
}

@target(javascript)
fn do_contains(haystack: String, needle: String) -> Bool {
  index_of(haystack, needle) != -1
}

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "index_of")
fn index_of(a: String, b: String) -> Int

/// Checks whether the first `String` starts with the second one.
///
/// ## Examples
///
/// ```gleam
/// > starts_with("theory", "ory")
/// False
/// ```
///
pub fn starts_with(string: String, prefix: String) -> Bool {
  do_starts_with(string, prefix)
}

@external(erlang, "gleam_stdlib", "string_starts_with")
@external(javascript, "../gleam_stdlib.mjs", "starts_with")
fn do_starts_with(a: String, b: String) -> Bool

/// Checks whether the first `String` ends with the second one.
///
/// ## Examples
///
/// ```gleam
/// > ends_with("theory", "ory")
/// True
/// ```
///
pub fn ends_with(string: String, suffix: String) -> Bool {
  do_ends_with(string, suffix)
}

@external(erlang, "gleam_stdlib", "string_ends_with")
@external(javascript, "../gleam_stdlib.mjs", "ends_with")
fn do_ends_with(a: String, b: String) -> Bool

/// Creates a list of `String`s by splitting a given string on a given substring.
///
/// ## Examples
///
/// ```gleam
/// > split("home/gleam/desktop/", on: "/")
/// ["home", "gleam", "desktop", ""]
/// ```
///
pub fn split(x: String, on substring: String) -> List(String) {
  case substring {
    "" -> to_graphemes(x)
    _ ->
      x
      |> string_builder.from_string
      |> string_builder.split(on: substring)
      |> list.map(with: string_builder.to_string)
  }
}

/// Splits a `String` a single time on the given substring.
///
/// Returns an `Error` if substring not present.
///
/// ## Examples
///
/// ```gleam
/// > split_once("home/gleam/desktop/", on: "/")
/// Ok(#("home", "gleam/desktop/"))
/// ```
///
/// ```gleam
/// > split_once("home/gleam/desktop/", on: "?")
/// Error(Nil)
/// ```
///
pub fn split_once(
  x: String,
  on substring: String,
) -> Result(#(String, String), Nil) {
  do_split_once(x, substring)
}

@target(erlang)
@external(erlang, "string", "split")
fn erl_split(a: String, b: String) -> List(String)

@target(erlang)
fn do_split_once(x: String, substring: String) -> Result(#(String, String), Nil) {
  case erl_split(x, substring) {
    [first, rest] -> Ok(#(first, rest))
    _ -> Error(Nil)
  }
}

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "split_once")
fn do_split_once(
  x x: String,
  substring substring: String,
) -> Result(#(String, String), Nil)

/// Creates a new `String` by joining two `String`s together.
///
/// This function copies both `String`s and runs in linear time. If you find
/// yourself joining `String`s frequently consider using the [`string_builder`](../gleam/string_builder.html)
/// module as it can append `String`s much faster!
///
/// ## Examples
///
/// ```gleam
/// > append(to: "butter", suffix: "fly")
/// "butterfly"
/// ```
///
pub fn append(to first: String, suffix second: String) -> String {
  first
  |> string_builder.from_string
  |> string_builder.append(second)
  |> string_builder.to_string
}

/// Creates a new `String` by joining many `String`s together.
///
/// This function copies both `String`s and runs in linear time. If you find
/// yourself joining `String`s frequently consider using the [`string_builder`](../gleam/string_builder.html)
/// module as it can append `String`s much faster!
///
/// ## Examples
///
/// ```gleam
/// > concat(["never", "the", "less"])
/// "nevertheless"
/// ```
///
pub fn concat(strings: List(String)) -> String {
  strings
  |> string_builder.from_strings
  |> string_builder.to_string
}

/// Creates a new `String` by repeating a `String` a given number of times.
///
/// This function runs in linear time.
///
/// ## Examples
///
/// ```gleam
/// > repeat("ha", times: 3)
/// "hahaha"
/// ```
///
pub fn repeat(string: String, times times: Int) -> String {
  iterator.repeat(string)
  |> iterator.take(times)
  |> iterator.to_list
  |> concat
}

/// Joins many `String`s together with a given separator.
///
/// This function runs in linear time.
///
/// ## Examples
///
/// ```gleam
/// > join(["home","evan","Desktop"], with: "/")
/// "home/evan/Desktop"
/// ```
///
pub fn join(strings: List(String), with separator: String) -> String {
  do_join(strings, separator)
}

@target(erlang)
fn do_join(strings: List(String), separator: String) -> String {
  strings
  |> list.intersperse(with: separator)
  |> concat
}

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "join")
fn do_join(strings strings: List(String), string string: String) -> String

/// Pads a `String` on the left until it has at least given number of graphemes.
///
/// ## Examples
///
/// ```gleam
/// > pad_left("121", to: 5, with: ".")
/// "..121"
/// ```
///
/// ```gleam
/// > pad_left("121", to: 3, with: ".")
/// "121"
/// ```
///
/// ```gleam
/// > pad_left("121", to: 2, with: ".")
/// "121"
/// ```
///
pub fn pad_left(string: String, to desired_length: Int, with pad_string: String) {
  let current_length = length(string)
  let to_pad_length = desired_length - current_length
  padding(to_pad_length, pad_string)
  |> iterator.append(iterator.single(string))
  |> iterator.to_list
  |> concat
}

/// Pads a `String` on the right until it has a given length.
///
/// ## Examples
///
/// ```gleam
/// > pad_right("123", to: 5, with: ".")
/// "123.."
/// ```
///
/// ```gleam
/// > pad_right("123", to: 3, with: ".")
/// "123"
/// ```
///
/// ```gleam
/// > pad_right("123", to: 2, with: ".")
/// "123"
/// ```
///
pub fn pad_right(
  string: String,
  to desired_length: Int,
  with pad_string: String,
) {
  let current_length = length(string)
  let to_pad_length = desired_length - current_length
  iterator.single(string)
  |> iterator.append(padding(to_pad_length, pad_string))
  |> iterator.to_list
  |> concat
}

fn padding(size: Int, pad_string: String) -> Iterator(String) {
  let pad_length = length(pad_string)
  let num_pads = size / pad_length
  let extra = size % pad_length
  iterator.repeat(pad_string)
  |> iterator.take(num_pads)
  |> iterator.append(iterator.single(slice(pad_string, 0, extra)))
}

/// Removes whitespace on both sides of a `String`.
///
/// ## Examples
///
/// ```gleam
/// > trim("  hats  \n")
/// "hats"
/// ```
///
pub fn trim(string: String) -> String {
  do_trim(string)
}

@target(erlang)
fn do_trim(string: String) -> String {
  erl_trim(string, Both)
}

@target(erlang)
type Direction {
  Leading
  Trailing
  Both
}

@target(erlang)
@external(erlang, "string", "trim")
fn erl_trim(a: String, b: Direction) -> String

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "trim")
fn do_trim(string string: String) -> String

/// Removes whitespace on the left of a `String`.
///
/// ## Examples
///
/// ```gleam
/// > trim_left("  hats  \n")
/// "hats  \n"
/// ```
///
pub fn trim_left(string: String) -> String {
  do_trim_left(string)
}

@target(erlang)
fn do_trim_left(string: String) -> String {
  erl_trim(string, Leading)
}

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "trim_left")
fn do_trim_left(string string: String) -> String

/// Removes whitespace on the right of a `String`.
///
/// ## Examples
///
/// ```gleam
/// > trim_right("  hats  \n")
/// "  hats"
/// ```
///
pub fn trim_right(string: String) -> String {
  do_trim_right(string)
}

@target(erlang)
fn do_trim_right(string: String) -> String {
  erl_trim(string, Trailing)
}

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "trim_right")
fn do_trim_right(string string: String) -> String

/// Splits a non-empty `String` into its first element (head) and rest (tail).
/// This lets you pattern match on `String`s exactly as you would with lists.
///
/// ## Examples
///
/// ```gleam
/// > pop_grapheme("gleam")
/// Ok(#("g", "leam"))
/// ```
///
/// ```gleam
/// > pop_grapheme("")
/// Error(Nil)
/// ```
///
pub fn pop_grapheme(string: String) -> Result(#(String, String), Nil) {
  do_pop_grapheme(string)
}

@external(erlang, "gleam_stdlib", "string_pop_grapheme")
@external(javascript, "../gleam_stdlib.mjs", "pop_grapheme")
fn do_pop_grapheme(string string: String) -> Result(#(String, String), Nil)

/// Converts a `String` to a list of
/// [graphemes](https://en.wikipedia.org/wiki/Grapheme).
///
/// ```gleam
/// > to_graphemes("abc")
/// ["a", "b", "c"]
/// ```
///
pub fn to_graphemes(string: String) -> List(String) {
  do_to_graphemes(string, [])
  |> list.reverse
}

fn do_to_graphemes(string: String, acc: List(String)) -> List(String) {
  case pop_grapheme(string) {
    Ok(#(grapheme, rest)) -> do_to_graphemes(rest, [grapheme, ..acc])
    _ -> acc
  }
}

@external(erlang, "gleam_stdlib", "identity")
@external(javascript, "../gleam_stdlib.mjs", "codepoint")
fn unsafe_int_to_utf_codepoint(a: Int) -> UtfCodepoint

/// Converts a `String` to a `List` of `UtfCodepoint`.
///
/// See <https://en.wikipedia.org/wiki/Code_point> and
/// <https://en.wikipedia.org/wiki/Unicode#Codespace_and_Code_Points> for an
/// explanation on code points.
///
/// ## Examples
///
/// ```gleam
/// > "a" |> to_utf_codepoints
/// [UtfCodepoint(97)]
/// ```
///
/// ```gleam
/// // Semantically the same as:
/// // ["🏳", "️", "‍", "🌈"] or:
/// // [waving_white_flag, variant_selector_16, zero_width_joiner, rainbow]
/// > "🏳️‍🌈" |> to_utf_codepoints
/// [UtfCodepoint(127987), UtfCodepoint(65039), UtfCodepoint(8205), UtfCodepoint(127752)]
/// ```
///
pub fn to_utf_codepoints(string: String) -> List(UtfCodepoint) {
  do_to_utf_codepoints(string)
}

@target(erlang)
fn do_to_utf_codepoints(string: String) -> List(UtfCodepoint) {
  do_to_utf_codepoints_impl(bit_string.from_string(string), [])
  |> list.reverse
}

@target(erlang)
fn do_to_utf_codepoints_impl(
  bit_string: BitString,
  acc: List(UtfCodepoint),
) -> List(UtfCodepoint) {
  case bit_string {
    <<first:utf8_codepoint, rest:binary>> ->
      do_to_utf_codepoints_impl(rest, [first, ..acc])
    <<>> -> acc
  }
}

@target(javascript)
fn do_to_utf_codepoints(string: String) -> List(UtfCodepoint) {
  string
  |> string_to_codepoint_integer_list
  |> list.map(unsafe_int_to_utf_codepoint)
}

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "string_to_codepoint_integer_list")
fn string_to_codepoint_integer_list(a: String) -> List(Int)

/// Converts a `List` of `UtfCodepoint`s to a `String`.
///
/// See <https://en.wikipedia.org/wiki/Code_point> and
/// <https://en.wikipedia.org/wiki/Unicode#Codespace_and_Code_Points> for an
/// explanation on code points.
///
/// ## Examples
///
/// ```gleam
/// > {
/// >   let assert #(Ok(a), Ok(b), Ok(c)) = #(
/// >     utf_codepoint(97),
/// >     utf_codepoint(98),
/// >     utf_codepoint(99),
/// >   )
/// >   [a, b, c]
/// > }
/// > |> from_utf_codepoints
/// "abc"
/// ```
///
pub fn from_utf_codepoints(utf_codepoints: List(UtfCodepoint)) -> String {
  do_from_utf_codepoints(utf_codepoints)
}

@target(erlang)
fn do_from_utf_codepoints(utf_codepoints: List(UtfCodepoint)) -> String {
  let assert Ok(string) =
    do_from_utf_codepoints_impl(utf_codepoints, bit_string.from_string(""))
    |> bit_string.to_string
  string
}

@target(erlang)
fn do_from_utf_codepoints_impl(
  utf_codepoints: List(UtfCodepoint),
  acc: BitString,
) -> BitString {
  case utf_codepoints {
    [first, ..rest] ->
      do_from_utf_codepoints_impl(
        rest,
        <<acc:bit_string, first:utf8_codepoint>>,
      )
    [] -> acc
  }
}

@target(javascript)
fn do_from_utf_codepoints(utf_codepoints: List(UtfCodepoint)) -> String {
  utf_codepoint_list_to_string(utf_codepoints)
}

@target(javascript)
@external(javascript, "../gleam_stdlib.mjs", "utf_codepoint_list_to_string")
fn utf_codepoint_list_to_string(a: List(UtfCodepoint)) -> String

/// Converts an integer to a `UtfCodepoint`.
///
/// Returns an `Error` if the integer does not represent a valid UTF codepoint.
///
pub fn utf_codepoint(value: Int) -> Result(UtfCodepoint, Nil) {
  case value {
    i if i > 1_114_111 -> Error(Nil)
    65_534 | 65_535 -> Error(Nil)
    i if i >= 55_296 && i <= 57_343 -> Error(Nil)
    i -> Ok(unsafe_int_to_utf_codepoint(i))
  }
}

/// Converts an UtfCodepoint to its ordinal code point value.
///
/// ## Examples
///
/// ```gleam
/// > utf_codepoint_to_int(128013) |> to_utf_codepoint_int
/// 128013
/// ```
///
pub fn utf_codepoint_to_int(cp: UtfCodepoint) -> Int {
  do_utf_codepoint_to_int(cp)
}

@external(erlang, "gleam_stdlib", "identity")
@external(javascript, "../gleam_stdlib.mjs", "utf_codepoint_to_int")
fn do_utf_codepoint_to_int(cp cp: UtfCodepoint) -> Int

/// Converts a `String` into `Option(String)` where an empty `String` becomes
/// `None`.
///
/// ## Examples
///
/// ```gleam
/// > to_option("")
/// None
/// ```
///
/// ```gleam
/// > to_option("hats")
/// Some("hats")
/// ```
///
pub fn to_option(s: String) -> Option(String) {
  case s {
    "" -> None
    _ -> Some(s)
  }
}

/// Returns the first grapheme cluster in a given `String` and wraps it in a
/// `Result(String, Nil)`. If the `String` is empty, it returns `Error(Nil)`.
/// Otherwise, it returns `Ok(String)`.
///
/// ## Examples
///
/// ```gleam
/// > first("")
/// Error(Nil)
/// ```
///
/// ```gleam
/// > first("icecream")
/// Ok("i")
/// ```
///
pub fn first(s: String) -> Result(String, Nil) {
  case pop_grapheme(s) {
    Ok(#(first, _)) -> Ok(first)
    Error(e) -> Error(e)
  }
}

/// Returns the last grapheme cluster in a given `String` and wraps it in a
/// `Result(String, Nil)`. If the `String` is empty, it returns `Error(Nil)`.
/// Otherwise, it returns `Ok(String)`.
///
/// ## Examples
///
/// ```gleam
/// > last("")
/// Error(Nil)
/// ```
///
/// ```gleam
/// > last("icecream")
/// Ok("m")
/// ```
///
pub fn last(s: String) -> Result(String, Nil) {
  case pop_grapheme(s) {
    Ok(#(first, "")) -> Ok(first)
    Ok(#(_, rest)) -> Ok(slice(rest, -1, 1))
    Error(e) -> Error(e)
  }
}

/// Creates a new `String` with the first grapheme in the input `String`
/// converted to uppercase and the remaining graphemes to lowercase.
///
/// ## Examples
///
/// ```gleam
/// > capitalise("mamouna")
/// "Mamouna"
/// ```
///
pub fn capitalise(s: String) -> String {
  case pop_grapheme(s) {
    Ok(#(first, rest)) -> append(to: uppercase(first), suffix: lowercase(rest))
    _ -> ""
  }
}

/// Returns a `String` representation of a term in Gleam syntax.
///
pub fn inspect(term: anything) -> String {
  do_inspect(term)
  |> string_builder.to_string
}

@external(erlang, "gleam_stdlib", "inspect")
@external(javascript, "../gleam.mjs", "inspect")
fn do_inspect(term term: anything) -> StringBuilder

/// Returns the number of bytes in a `String`.
/// 
/// This function runs in constant time on Erlang and in linear time on
/// JavaScript.
///
pub fn byte_size(string: String) -> Int {
  do_byte_size(string)
}

@external(erlang, "erlang", "byte_size")
@external(javascript, "../gleam_stdlib.mjs", "byte_size")
fn do_byte_size(a: String) -> Int
