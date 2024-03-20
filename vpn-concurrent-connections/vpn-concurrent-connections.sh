fw tab -t userc_users -s | awk '{print $4}' | grep -v -e "#VALS"
