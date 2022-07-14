module token

pub const (
	token_str = build_token_str()
	keywords = build_keys()
)

pub enum Kind {
	unknown
	ident
	eof
	keyword_beginning
	keyword_proc
	keyword_return
	keyword_end
	_end_
}

fn build_token_str() []string {
	mut s := []string{len: int(Kind._end_)}
	s[Kind.unknown] = 'unknown'
	s[Kind.ident] = 'ident'
	s[Kind.eof] = 'eof'

	s[Kind.keyword_beginning] = 'keyword_beginning'
	
	s[Kind.keyword_proc] = 'proc'
	s[Kind.keyword_return] = 'return'
	
	s[Kind.keyword_end] = 'keyword_end'

	return s
}

fn build_keys() map[string]Kind {
	mut res := map[string]Kind{}
	for t in int(Kind.keyword_beginning) + 1 .. int(Kind.keyword_end) {
		key := token.token_str[t]
		res[key] = Kind(t)
	}
	return res
}

pub struct Token {
pub mut:
	kind Kind
	raw string
	len int
	line int
	col int
	position int
	token_index int
}