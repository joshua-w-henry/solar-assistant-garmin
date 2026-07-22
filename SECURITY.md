# Security policy

## Credential model

The current version uses a build-time bearer token stored in `source/SolarConfig.mc`. That value is compiled into `.prg` and `.iq` packages and should be considered extractable.

Use only a dedicated bridge token with these properties:

- Read-only
- Restricted to the solar summary endpoint
- Easy to rotate
- Unrelated to administrator, SSH, Solar Assistant, Home Assistant, or cloud-account credentials

## Files that must remain private

Never commit or publish:

```text
source/SolarConfig.mc
*.prg
*.iq
*.key
*.der
*.pem
*.p12
*.pfx
```

The repository includes a safe example at `config/SolarConfig.example.mc`.

## Accidental disclosure

If a real token enters Git history or a distributed binary:

1. Revoke or rotate the token immediately.
2. Replace the affected build.
3. Remove the secret from Git history; deleting it in a later commit is not sufficient.
4. Review bridge logs for unauthorized access.

## Reporting a vulnerability

Open a GitHub security advisory when available. Do not post live tokens, private endpoints, or exploit details in a public issue.
