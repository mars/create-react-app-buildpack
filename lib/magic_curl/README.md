Magic cUrl
==========

Magic cUrl is a simple caching wrapper around the cUrl command. 
It can be placed before the real cUrl command in the $PATH to cache downloaded files so they can be subsequently downloaded faster.

Usage
-----

To use Magic cUrl, place its `/bin` dir before the real cUrl command in your $PATH. For example:

    export PATH=/usr/bin/local/magic_cache/bin:$PATH

Once this is set, use the `curl` command like you normally would. Magic cUrl will automatically forward all arguments to the real cUrl command if a local copy is not found in the cache.

The cache location defaults to `/tmp/magic_curl_cache`, but can be changed in the `conf/cache.conf` file.

Run `cache-clear` to clear the cache. 
