/*
Language: V
Author: Alex Medvednikov <alexander@medvednikov.com>
Description: The V Programming Language (vlang). For info about language
Website: http://vlang.org/
Category: common, system
*/

(() => {
  const f = m => {
    const LITERALS = [
      "true",
      "false",
      "nil"
    ];
    const BUILT_INS = [
      "close",
      "dump",
      "eprint",
      "eprintln",
      "error",
      "exit",
      "it",
      "panic",
      "print_backtrace",
      "print",
      "println",

    ];
    const TYPES = [
      "bool",
      "string",
      "i8", "i16", "i32", "i64", "i128", "int",
      "u8", "u16", "u32", "u64", "u128",
      "rune",
      "f32", "f64",
      "isize", "usize",
      "voidptr", "charptr", "byteptr", "thread"
    ];
    const KWS = [
      "as",
      "asm",
      "assert",
      "atomic",
      "break",
      "const",
      "continue",
      "defer",
      "else",
      "enum",
      "fn",
      "for",
      "go",
      "goto",
      "if",
      "import",
      "in",
      "interface",
      "is",
      "isreftype",
      "lock",
      "match",
      "module",
      "mut",
      "nil",
      "none",
      "or",
      "pub",
      "return",
      "rlock",
      "select",
      "shared",
      "sizeof",
      "spawn",
      "static",
      "struct",
      "type",
      "typeof",
      "union",
      "unsafe",
      "volatile",
      "__global",
      "__offsetof"
    ];
    const KEYWORDS = {
      keyword: KWS,
      type: TYPES,
      literal: LITERALS,
      built_in: BUILT_INS
    };
    return {
      name: 'V',
      aliases: [ 'vlang' ],
      keywords: KEYWORDS,
      illegal: '</',
      contains: [
        m.C_LINE_COMMENT_MODE,
        m.C_BLOCK_COMMENT_MODE,
        {
          className: 'string',
          variants: [
            m.QUOTE_STRING_MODE,
            m.APOS_STRING_MODE,
            {
              begin: '`',
              end: '`'
            }
          ]
        },
        {
          className: 'number',
          variants: [
            {
              begin: m.C_NUMBER_RE + '[i]',
              relevance: 1
            },
            m.C_NUMBER_MODE
          ]
        },
        { begin: /:=/ // relevance booster
        },
        {
          className: 'function',
          beginKeywords: 'fn',
          end: '\\s*(\\{|$)',
          excludeEnd: true,
          contains: [
            m.TITLE_MODE,
            {
              className: 'params',
              begin: /\(/,
              end: /\)/,
              endsParent: true,
              keywords: KEYWORDS,
              illegal: /["']/
            }
          ]
        }
      ]
    };
  };
  hljs.registerLanguage('v', f);
})();