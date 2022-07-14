module scanner

import os
import term
import token
import math
import v.util

const (
	tab = 9
	space = 32
	nel = 0x85
	nbs = 0xa0
	line_feed = 10
	carriage_return = 13
)

pub struct Scanner {
pub mut:
	file_path string
	contents string
	verbosity int
	line int
	line_amount int
	last_newline int = -1
	position int
	token_index int	
	tokens []token.Token
	is_in_string bool
	is_crlf bool
	should_halt bool
}

pub fn scanner_from_file(file_path string, verbosity int) ?Scanner {
	if verbosity > 0 { println("> Creating Scanner instance.") }

	if verbosity > 1 { println(">> Trying to read file `$file_path`.") }

	contents := os.read_file(file_path) or {
		return none
	}

	if verbosity > 1 { println(term.bright_green(">> Read file successfully."))}
	if verbosity > 0 { println(term.bright_green("> Created Scanner instance."))}

	return Scanner {
		file_path: file_path
		contents: contents
		verbosity: verbosity
		tokens: []token.Token{}
	}
}

pub fn (mut s Scanner) scan() {
	for {
		token := s.next_token()
		s.tokens << token
		if token.kind == .eof || s.should_halt {
			break
		}
	}
}

fn (mut s Scanner) ident_name() string {
	start := s.position
	s.position++

	for s.position < s.contents.len {
		c := s.contents[s.position]
		if (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || (c >= `0` && c <= `9`) || c == `_` {
			s.position ++
			continue
		}
		break
	}
	name := s.contents[start..s.position]
	s.position --
	return name
}

fn (mut s Scanner) next_token() token.Token {
	for {
		
		if !s.is_in_string {
			s.skip_whitespace()
		}

		if s.position >= s.contents.len || s.should_halt {
			return s.eof_token()
		}

		character := s.contents[s.position]
		next_character := s.peek(1)

		if util.is_name_char(character) {
			ident := s.ident_name()
			kind := token.keywords[ident]
			if int(kind) != 0 { 
				return s.new_token(token.Kind(kind), ident, ident.len)
			}
		}

		s.position ++
	}
	return token.Token{}
}

[inline]
fn (mut s Scanner) new_token(token_kind token.Kind, raw string, len int) token.Token {
	tidx := s.token_index
	s.token_index ++
	return token.Token {
		kind: token_kind
		raw: raw
		line: s.line
		col: math.max(1, s.current_col() - len + 1)
		position: s.position - len + 1
		len: len
		token_index: tidx
	}
}

fn (mut s Scanner) skip_whitespace() {
	for s.position < s.contents.len {
		character := s.contents[s.position]
		if character == tab {
			// Tab
			s.position ++
			continue
		}

		if !(character == space || (character > 8 && character < 14) || (character == nel) || (character == nbs)) {
			return
		}

		if s.position + 1 < s.contents.len && character == carriage_return && s.contents[s.position + 1] == line_feed {
			s.is_crlf = true
		}

		if (character == carriage_return || character == line_feed) && 
			!(s.position > 0 && s.contents[s.position - 1] == carriage_return && character == line_feed) {
				s.next_line()
		}
		s.position ++
	}
}

[inline]
fn (mut s Scanner) next_line() {
	s.last_newline = math.min(s.contents.len - 1, s.position)
	if s.is_crlf {
		s.last_newline++
	}
	s.line ++
	if s.line > s.line_amount {
		s.line_amount = s.line
	}
}

fn (s &Scanner) peek(amount int) u8 {
	if s.position + amount < s.contents.len {
		return s.contents[s.position + amount]
	}
	return `\0`
}

[inline]
fn (s &Scanner) current_col() int {
	return s.position - s.last_newline
}

[inline]
fn (s &Scanner) eof_token() token.Token {
	return token.Token {
		kind: .eof
		raw: ''
		len: 1
		line: s.line
		col: s.current_col()
		token_index: s.token_index
	}
}