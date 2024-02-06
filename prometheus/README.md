# prometheus-cookbook
#
# Maintainer Nizam Uddin <nizam.hbti@gmail.com>
#
#
#
# ################################################
# Monitoring : Prometheus HA setup (Two machines)
# ################################################


# Issues:

pq: password authentication failed for user postgres
Solution: Go to db, connect docker contaianer, check prometheus/pg_hba.conf, checkk trust or md5 auth method.
