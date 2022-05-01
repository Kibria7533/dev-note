### I had the probelem that my kubernetes dashboard was on ec2 local some port so how could i access it

Then i enable icmp inbound and outbound traffic but didnt workd then finaly notish that i didnt run command for creating dashboard
After then it failed to connect to github but able to google so i chagned the nameserver.
But but the resolv.conf was not being permanently changed.So i had to change there
`sudo vi /run/systemd/resolve/stub-resolv.conf`
make the nameserver 8.8.8.8 and check it can now ping github.com
and then
`sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`

Now as its everything similar my other kubernetes cluster setup and for getting dashboard also