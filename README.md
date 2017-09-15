# Theta Tunnel Script

Due to how the machine is configured, it's not currently possible to open a
reverse ssh tunnel from a compute node back to a login node, since it
incorrectly routes you through the firewall and thus requires you to enter your
crypto-card. Instead to tunnel into a compute node and connect to some vis-app
server running there you must perform 2 hops of SSH tunneling + 1 hop of
[socat](http://www.dest-unreach.org/socat/doc/socat.html) to get the connection
through. socat is not installed on Theta but it's quick to
[build from source](http://www.dest-unreach.org/socat/). The last hop of socat
is required because you can't ssh directly onto the compute nodes at all. The
commands to setup the connection are:

1. First tunnel into any theta login node.
```ssh -L port:localhost:port user@theta.alcf.anl.gov```

1. Next tunnel into any mom node. The mom node # is not important, as
they can see all compute nodes on the network.
```ssh -L port:localhost:port thetamom#```

1. On the mom node run `socat` to bridge between the ssh tunnel and the
TCP socket (or whatever socket you open) running on the compute node.
```socat TCP-LISTEN:port TCP:nid#####:port```

You can now connect your client running on your desktop to `localhost:port`
and it will tunnel through to the server running on the compute node.
The network connections look like so:

```text
      ssh -L X:localhost:X \            ssh -L X:localhost:X \       socat TCP-LISTEN:X \
         theta.alcf.anl.gov                    thetamom1                   TCP:nid#####:X
Desk ---------------------------> Login ----------------------> mom1 --------------------> nid#####
```

The script provided in this repo executes this sequence of commands using SSH
remote command execution.

## Script Usage

Usage: `./theta-tunnel.sh <user name> <worker id> <port>`

The script will tunnel the local port `<port>` through
to a connection on Theta compute node `nid<worker id>:<port>`
allowing you to connect to a remote running vis client.
You should enter the worker id without any leading zeros.

