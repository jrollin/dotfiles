return {
  { "nvim-neotest/neotest-jest" },
  { "marilari88/neotest-vitest" },
  { "nvim-neotest/neotest-python" },
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        "neotest-jest",
        "neotest-vitest",
        "neotest-python",
      },
    },
  },
}
