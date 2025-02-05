
# uv (uv)

An extremely fast Python package and project manager, written in Rust.

## Example Usage

```json
"features": {
    "ghcr.io/va-h/devcontainers-features/uv:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version to install. | string | latest |
| shellautocompletion | Enable or disable uv and uvx autocompletion. | boolean | false |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/va-h/devcontainers-features/blob/main/src/uv/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
