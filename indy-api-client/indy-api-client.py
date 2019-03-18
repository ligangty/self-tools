import os
import argparse
import sys

def main():
    desc = "Indy api client with authentication to keycloak."
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--kc_host',  type=str, 
                        help='keycloak server host, not provided means no authentication needed.')
    parser.add_argument('--kc_prj', metavar='-p', type=str, 
                        help='keycloak project name, not provided means no authentication needed.')
    parser.add_argument('--indy_host', metavar='-i', type=str, required=True,
                        help='indy host which to connect to.')
    args = parser.parse_args()

    kcHost = args.kc_host, kcPrj = args.kc_prj
    authNeed = (kcHost is not None) and (kcPrj is not None)


    print("auth needed: %s" % authNeed )
    

if __name__=="__main__": main()


