

# https://www.shellcheck.net/wiki/
# https://www.shellcheck.net/

# https://github.com/koalaman/shellcheck/blob/master/README.md#user-content-gallery-of-bad-code
# https://github.com/koalaman/shellcheck/wiki/Ignore

```bash
apt install shellcheck
shellcheck --version
```

Exceptions :

1. Per Command :

shellcheck disable=SC2116,SC2086
command_name command_args...

2. Per Run :

shellcheck -e SC2059 script_name

3. Per File :

#!/bin/sh
# shellcheck disable=all


# shellcheck disable=SC2034

# shellcheck disable=SC2086

4. Per Project ( .shellcheckrc ) file in root path :

disable=SC2059,SC2034




