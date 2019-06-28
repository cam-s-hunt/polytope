# polytope

Based on the excellent work done by @ianblenk: https://github.com/ianblenke/termux-tor-ssh-ipfs. 

Android-only DevOps

## Requirements

1. Android phone
2. Termux
3. A Github account with an ssh public key and privately-accessible corresponding private key

## Installation:

1. Start Termux
2. Run the following command:

    pkg install curl && curl -sL https://raw.githubusercontent.com/cam0sum/polytope/master/run.sh | GITHUB_USERS=<your_github_username> sh -x

3. After a `exit` and a restart of TermUX, it should show you your hidden service onion address, which should look something like this:

    u0_a118@bhffkxuwbzw3b46l2dqm2dykagiktjdi274twmhnblx4rxdsjxqxzsad.onion. Proceed with install Y/N?

4. Once you have made a copy of the user account (ex: u0_a118) and the *.onion address, type `Y` on the Android keyboard to continue the installation process.
5. Once the installation is complete, the phone will participate in the polytope network until Termux is stopped (forceably or accidentally)

## Remote Access
1. Install and start Tor on the device you will use to access the phone remotely (this will enable a Tor proxy)
2. Configure your ssh client to use the Tor proxy to get ssh access to the phone. For Linux systems, add the following to your ~/.ssh/config file (create the file if it doesn't already exist):

    host pixel
    User u0_a118
    IdentityFile ~/.ssh/id_rsa # this should be the private key that matches the public key of the account you specified in GITHUB_USERS in step #2
    Hostname bhffkxuwbzw3b46l2dqm2dykagiktjdi274twmhnblx4rxdsjxqxzsad.onion
    ProxyCommand nc -x 127.0.0.1:9050 %h %p

If MacOS systems, use the following format instead:

    host myphone
    User u0_a118
    IdentityFile ~/.ssh/id_rsa-ianblenke@github.com
    ProxyCommand ncat --proxy 127.0.0.1:9050 --proxy-type socks5 bhffkxuwbzw3b46l2dqm2dykagiktjdi274twmhnblx4rxdsjxqxzsad.onion 22
    
2. Once properly configured, just type the following command to connect to the phone's ssh server over Tor:

    ssh myphone


Overall Strategy:

Bootstrap
- id/auth (keys, account) for human & compute
    - ssb
    - requires master account
    - requires registry function
- all as code
    - git-ssb
- mobile CI/CD pipeline
    - gitlab on arm64 (Pixel)
    - runners on:
        - arm64 (oneplus)
        - arm7 (samsung 7, redmi 4)
- ops options
    - termux-compliant (user-space, chroots, etc)
        - need crypto incentive framework
            - existing generic "plug in" frameworks?
            - bashify
    - container-based: akash.network
