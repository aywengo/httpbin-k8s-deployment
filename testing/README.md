# Testing httpbin Deployment

`testing/test_httpbin.sh` runs smoke checks against a httpbin host.

## Usage
```
./testing/test_httpbin.sh <host>
```

- Requires `curl`
- Reports `[PASS]`/`[FAIL]`; non-zero exit on failure

## Coverage
- `GET /status/200`
- `GET /delay/1`
- `GET /anything/test`
- `POST /post`
- `GET /uuid`

Extend by adding more httpbin endpoints as needed.

