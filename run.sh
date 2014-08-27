#!/bin/bash
CFG=${CFG:-}
ES_HOST=${ES_PORT_9300_TCP_ADDR:-127.0.0.1}
ES_PORT=${ES_PORT_9300_TCP_PORT:-9300}
EMBEDDED="false"

if [ "$ES_HOST" = "127.0.0.1" ] ; then
    EMBEDDED="true"
fi

if [ "$CFG" != "" ]; then
    wget $CFG -O /opt/logstash/logstash.conf --no-check-certificate
else
    cat << EOF > /opt/logstash/logstash.conf
input {
  syslog {
    type => syslog
    port => 514
  }
}
output {
  stdout { }
EOF
    if [ "$EMBEDDED" = "true" ]; then
        cat << EOF >> /opt/logstash/logstash.conf
  elasticsearch { embedded => $EMBEDDED }
}
EOF
    else
        cat << EOF >> /opt/logstash/logstash.conf
  elasticsearch { embedded => $EMBEDDED host => "$ES_HOST" port => $ES_PORT protocol => "http" }
}
EOF
   fi
fi

/opt/logstash/bin/logstash agent -f /opt/logstash/logstash.conf -- web --backend elasticsearch://$ES_HOST:$ES_PORT/
