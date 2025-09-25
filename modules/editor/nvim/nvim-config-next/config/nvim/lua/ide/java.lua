vim.pack.add({
  { src = 'https://github.com/williamboman/mason.nvim' },
  { src = 'https://github.com/nvim-java/nvim-java' },
  { src = 'https://github.com/nvim-java/nvim-java-refactor' },
  { src = 'https://github.com/nvim-java/nvim-java-core' },
  { src = 'https://github.com/nvim-java/nvim-java-test' },
  { src = 'https://github.com/nvim-java/nvim-java-dap' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
  { src = 'https://github.com/nvim-java/lua-async-await' },
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/nvim-java/nvim-java' },
  { src = 'https://github.com/JavaHello/spring-boot.nvim' },
}, { confirm = false })
require('java').setup()
vim.lsp.enable('jdtls')
