## uv Repository

* [astral-sh/uv](https://github.com/astral-sh/uv)

## Autocompletion for other shells than Bash

When installing a shell via another feature, make sure to override the installation order to make sure that the autocomplatetion takes place. Here is an example installing the Fish shell and enabling autocompletion for it:

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
