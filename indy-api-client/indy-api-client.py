import os
import argparse
import sys

def main():
    desc = "Indy api client with authentication to keycloak."
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument( '-k', "--kc_host", type=str, 
                        help='keycloak server host, not provided means no authentication needed.')
    parser.add_argument( '-p', '--kc_prj', type=str, 
                        help='keycloak project name, not provided means no authentication needed.')
    parser.add_argument( '-i', "--indy_host", type=str, required=True,
                        help='indy host which to connect to.')
    args = parser.parse_args()
    for arg in vars(args):
        print(arg, getattr(args, arg))
   
    authNeed = (args.kc_host is not None) and (args.kc_prj is not None)
    if(authNeed):
        kcHost = args.kc_host 
        kcPrj = args.kc_prj
        kcAuthUrl = "%s/auth/realms/%s/protocol/openid-connect/token" % (kcHost,kcPrj)
        print(kcAuthUrl)

#        curl \
#  -d "client_id=admin-cli" \
#  -d "username=admin" \
#  -d "password=password" \
#  -d "grant_type=password" \
#  "http://localhost:8080/"

if __name__=="__main__": main()


