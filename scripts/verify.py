import brownie
from brownie import CookieCapital

def main():
  token = CookieCapital.at("0xfaCa84EE0cdF782df41c30fAc7a6aD9192f9E760")
  CookieCapital.publish_source(token)
