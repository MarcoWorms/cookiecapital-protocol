from brownie import CookieCapital, accounts

def main():
    acct = accounts.load('worms')
    CookieCapital.deploy("0x0dec85e74a92c52b7f708c4b10207d9560cefaf0", { 'from': acct.address })
    # CookieCapital.publish_source(CookieCapital.address)
