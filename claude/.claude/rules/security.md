## Security rules

- Never hardcode secrets, API keys, tokens, or credentials in source code
- Never commit .env files, private keys (.pem, .key), or token files
- Sanitize all user input at system boundaries
- Use parameterized queries — no string interpolation for SQL/NoSQL
- Flag any dependency with known CVEs during install
- Prefer short-lived tokens over long-lived credentials
