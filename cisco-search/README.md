# Cisco Search

As the name suggests the scripts intention is to search in cisco config files for a given search pattern and print the matching configuration part.
This comes handy if you have to find a switchport with a specific description among a bunch of swichtes in your environment.
Obviously this only works if you have unique switchport descriptions in your environment.

The path under which the configuration files are expected is hardcoded with /tmp/cisco-search - change this to your personal needs if needed.
Another thing to mention is that the search logic only works with the good old cisco flavored configurations (with a ! separating each section).
Configurations where a blank line is used as spearator are not supported (e.g. NXOS) - thank you for the consitency regarding configurations cisco!  
However, there is a simple workaround for this problem `perl -p -i -e 's/^\n$/!\n/' FILENAME`.

To have all the configurations extracted in the mentioned directory and automatically bring them in the correct format as described above 
I use the ansible playbook <cisco-search.yaml> which is fired once a day using a cronjob.
