-- API Test for Mistral Codestral FIM completions
-- Tests JavaScript and Python API responses

local auth = require("mistral-codestral.auth")
local api_key = auth.get_api_key()

print("=== Testing Mistral FIM API ===\n")

local test_cases = {
  -- JavaScript tests
  {
    name = "JavaScript: Simple return statement",
    prompt = "function sum(a, b) {\n  return ",
    suffix = "\n}",
  },
  {
    name = "JavaScript: Array map method",
    prompt = "const numbers = [1, 2, 3];\nconst doubled = numbers.",
    suffix = "\nconsole.log(doubled);",
  },
  {
    name = "JavaScript: Object method",
    prompt = "const calculator = {\n  add(a, b) {\n    return ",
    suffix = "\n  }\n}",
  },
  -- Python tests
  {
    name = "Python: Simple function return",
    prompt = "def sum(a, b):\n    return ",
    suffix = "\n",
  },
  {
    name = "Python: List comprehension",
    prompt = "numbers = [1, 2, 3, 4, 5]\nsquared = [",
    suffix = "]\nprint(squared)",
  },
  {
    name = "Python: Class init method",
    prompt = "class Calculator:\n    def __init__(self):\n        ",
    suffix = "\n\n    def add(self, a, b):\n        return a + b",
  },
}

local passed = 0
local failed = 0

local function test_completion(test_case, callback)
  print("Test: " .. test_case.name)

  local data = {
    model = "codestral-latest",
    prompt = test_case.prompt,
    suffix = test_case.suffix,
    max_tokens = 32,
    temperature = 0.0,
  }

  local json_data = vim.fn.json_encode(data)
  local temp_file = vim.fn.tempname()
  vim.fn.writefile({ json_data }, temp_file)

  local cmd = string.format(
    "curl -s -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer %s' -d @%s https://codestral.mistral.ai/v1/fim/completions",
    api_key,
    temp_file
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, output)
      if output and output[1] and output[1] ~= "" then
        local response_text = table.concat(output, "\n")
        local ok, response = pcall(vim.fn.json_decode, response_text)

        if ok and response then
          if response.choices and response.choices[1] then
            local completion = response.choices[1].message and response.choices[1].message.content
              or response.choices[1].text
            if completion and completion ~= "" then
              print("✓ Result: " .. completion:gsub("\n", "\\n"))
              passed = passed + 1
            else
              print("✗ Empty completion")
              failed = failed + 1
            end
          elseif response.error then
            print("✗ Error: " .. vim.inspect(response.error))
            failed = failed + 1
          else
            print("✗ Unexpected response")
            failed = failed + 1
          end
        else
          print("✗ JSON parse error")
          failed = failed + 1
        end
      end

      vim.fn.delete(temp_file)
      if callback then
        callback()
      end
    end,
  })
end

-- Run tests sequentially
local current_test = 1
local function run_next_test()
  if current_test <= #test_cases then
    test_completion(test_cases[current_test], function()
      print("")
      current_test = current_test + 1
      vim.defer_fn(run_next_test, 2000)
    end)
  else
    print("\n=== Test Summary ===")
    print(string.format("Passed: %d", passed))
    print(string.format("Failed: %d", failed))
    if failed == 0 then
      print("\n✓ All API tests passed!")
    else
      print("\n✗ Some API tests failed")
    end
    vim.defer_fn(function()
      vim.cmd("qa!")
    end, 1000)
  end
end

run_next_test()
vim.wait(30000)
