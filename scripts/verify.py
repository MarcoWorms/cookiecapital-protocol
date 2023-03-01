import brownie
from brownie import CookieCapital

def main():
  token = CookieCapital.at("0xcF0CD547E9d1a7C865F81CeB9F12e0D9fFA99C88")
  CookieCapital.publish_source(token)
