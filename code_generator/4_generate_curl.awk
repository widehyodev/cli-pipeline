BEGIN {
    FS = ","
    print "#!/bin/bash"
    print "set -euo pipefail"
}
NR > 1 {
    topic_id = substr($1, index($1, "=") + 1)
    printf "curl -s %s -o %s/%s.html\n", $1, html_dir, topic_id
}