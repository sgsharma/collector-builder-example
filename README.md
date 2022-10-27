# collector-builder-example

## Quickstart

```
# build docker image
docker build -t collector:local -f Dockerfile . --no-cache

# run docker container named test
docker run -d --name test -p 4317-4318:4317-4318 collector:local

# run docker exec curl command to check connectivity to HNY
docker exec -it test curl https://api.honeycomb.io/1/auth -X GET -H "X-Honeycomb-Team:<YOUR-API-KEY>"
```
