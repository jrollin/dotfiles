return {
  { "nvim-neotest/neotest-jest" },
  { "marilari88/neotest-vitest" },
  { "olimorris/neotest-phpunit" },
  { "nvim-neotest/neotest-python" },
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        "neotest-jest",
        "neotest-vitest",
        "neotest-phpunit",
        "neotest-python",
      },
    },
  },
}
