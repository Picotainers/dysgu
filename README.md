# dysgu
Container image for `dysgu`.

## Quick Usage
```bash
# Pull the image
docker pull docker.io/picotainers/dysgu:latest

# Run the tool
docker run --rm docker.io/picotainers/dysgu:latest --help
```

## Usage with input files
```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/dysgu:latest --help
```
