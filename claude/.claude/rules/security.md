## Security rules

- Never hardcode secrets, API keys, tokens, or credentials in source code
- Never commit .env files, private keys (.pem, .key), or token files
- Sanitize all user input at system boundaries
- Use parameterized queries — no string interpolation for SQL/NoSQL
- Never pass user-controlled data into query operators, projections, or `$where` clauses
- Never log secrets, tokens, or PII — even in error messages or stack traces
- Surface dependencies with known CVEs to the user before install — do not silently proceed
- Prefer short-lived tokens over long-lived credentials
- Auth/CSRF tokens must not appear in URLs or query strings — use headers or cookies
