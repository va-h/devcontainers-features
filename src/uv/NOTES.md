## uv Repository

* [astral-sh/uv](https://github.com/astral-sh/uv)

## Fix Autocompletion with feature Shells

> [!IMPORTANT]
> When installing a shell via another feature, make sure to override the installation order to ensure the generated autocompletion writes to existing files.

### Autocompletion for Fish Shell
 
```json
"features": {
    "ghcr.io/meaningful-ooo/devcontainer-features/fish:latest": {},
    "ghcr.io/va-h/devcontainers-features/uv:latest": {
        "shellautocompletion": true
    }
},
"overrideFeatureInstallOrder": [
    "ghcr.io/meaningful-ooo/devcontainer-features/fish",
    "ghcr.io/va-h/devcontainers-features/uv:latest"
]
```
