return {
  {
    'milanglacier/minuet-ai.nvim',
    config = function()
      require('minuet').setup {
        provider = 'gemini',
        virtualtext = {
          auto_trigger_ft = { '*' },
          disabled_auto_trigger_ft = { 'json' },
          keymap = {
            -- accept whole completion
            accept = '<C-b>',
            -- accept current completion line
            -- accept_line = '<A-a>',
            -- -- accept n lines (prompts for number)
            -- -- e.g. "A-z 2 CR" will accept 2 lines
            -- accept_n_lines = '<A-z>',
            --
            -- -- Cycle to prev completion item, or manually invoke completion
            -- prev = '<A-[>',
            -- -- Cycle to next completion item, or manually invoke completion
            -- next = '<A-]>',
            -- dismiss = '<A-e>',
          },
        },
        provider_options = {
          gemini = {
            model = 'gemini-2.0-flash',
            stream = true,
            end_point = 'https://generativelanguage.googleapis.com/v1beta/models',
            optional = {
              generationConfig = {
                maxOutputTokens = 256,
                thinkingConfig = {
                  thinkingBudget = 0,
                },
              },
            },
          },
        },
      }

      require('lualine').setup {
        sections = {
          lualine_x = {
            {
              require 'minuet.lualine',
              -- the follwing is the default configuration
              -- the name displayed in the lualine. Set to "provider", "model" or "both"
              -- display_name = 'both',
              -- separator between provider and model name for option "both"
              -- provider_model_separator = ':',
              -- whether show display_name when no completion requests are active
              -- display_on_idle = false,
            },
            'encoding',
            'fileformat',
            'filetype',
          },
        },
      }
    end,
  },
  { 'nvim-lua/plenary.nvim' },
  -- optional, if you are using virtual-text frontend, nvim-cmp is not
  -- required.
  { 'hrsh7th/nvim-cmp' },
  -- optional, if you are using virtual-text frontend, blink is not required.
  { 'Saghen/blink.cmp' },
}
