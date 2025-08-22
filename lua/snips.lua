return {
  config = function()
    local ls = require 'luasnip'
    local t = ls.text_node
    local i = ls.insert_node

    -- add pubf snippet for php public function (without overwriting others)
    ls.add_snippets('php', {
      ls.snippet({ trig = 'pubf' }, {
        t 'public function ',
        i(1),
        t '(',
        i(2),
        t ')',
        t { '', '{', '' },
        t '\t',
        i(3, ''),
        t { '', '}' },
      }),
      ls.snippet({ trig = 'prif' }, {
        t 'private function ',
        i(1),
        t '(',
        i(2),
        t ')',
        t { '', '{', '' },
        t '\t',
        i(3, ''),
        t { '', '}' },
      }),
      ls.snippet({ trig = 'pubsf' }, {
        t 'public static function ',
        i(1),
        t '(',
        i(2),
        t ')',
        t { '', '{', '' },
        t '\t',
        i(3, ''),
        t { '', '}' },
      }),
    })

    ls.add_snippets('vue', {
      ls.snippet({ trig = 'sfc' }, {
        t { '<script setup lang="ts">', '' },
        i(1),
        t { '', '</script>', '' },
        t { '' },
        t { '<template>', '' },
        i(2),
        t { '', '</template>', '' },
      }),
    })

    for _, lang in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue' } do
      ls.add_snippets(lang, {
        ls.snippet({ trig = 'sect' }, {
          t { '/*─────────────────────────────────────┐', '' },
          t { '│  ' },
          i(1),
          t { '                                   │', '' },
          t { '└─────────────────────────────────────*/', '' },
        }),

        ls.snippet({ trig = 'dprops' }, {
          t { 'const props = defineProps<{', '' },
          t { '\t' },
          i(1),
          t { '', '}>()' },
        }),

        ls.snippet({ trig = 'demit' }, {
          t { 'const emit = defineEmits<{', '' },
          t { '\t' },
          i(1),
          t { '', '}>()' },
        }),

        ls.snippet({ trig = 'dtr' }, {
          t { 'const trans = defineTranslations({', '' },
          t { '\t' },
          i(1),
          t { '', '})' },
        }),

        ls.snippet({
          trig = 'pinia',
        }, {
          t { 'export const use' },
          i(1),
          t { ' = defineStore("' },
          i(2),
          t { '", () => {', '' },
          t { '\t' },
          i(3),
          t { '', '});', '' },
        }),

        ls.snippet({ trig = 'clog' }, {
          t 'console.log(',
          i(1),
          t ')',
        }),

        ls.snippet({ trig = 'cmt' }, {
          t { '/**', '' },
          t { ' * ' },
          i(1),
          t { '', ' */' },
        }),

        -- arrow function with body
        ls.snippet({ trig = 'fb' }, {
          t { '(' },
          i(1),
          t { ') => {' },
          i(2),
          t { '}' },
        }),

        -- lambda arrow function
        ls.snippet({ trig = 'ff' }, {
          t { '() => ' },
          i(1),
        }),

        ls.snippet({ trig = 'fun' }, {
          t 'function ',
          i(1),
          t '(',
          i(2),
          t '): ',
          i(3),
          t { ' {', '' },
          t '\t',
          i(4),
          t { '', '}' },
        }),

        ls.snippet({ trig = 'afunc' }, {
          t 'async function ',
          i(1),
          t '(',
          i(2),
          t '): Promise<',
          i(3),
          t { '> {', '' },
          t '\t',
          i(4),
          t { '', '}' },
        }),
      })
    end
  end,
}
