# dysgu
Container image for `dysgu`.

## Quick Usage
```bash
# Pull the image
docker pull docker.io/picotainers/dysgu:latest

# Run the tool
docker run --rm docker.io/picotainers/dysgu:latest dysgu --help
```

## Usage with input files
```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/dysgu:latest dysgu --help
```

## Building

```bash
docker build -t docker.io/picotainers/dysgu:latest .
```
