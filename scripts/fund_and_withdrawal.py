from brownie import FundMe
from scripts.useful_scripts import get_account
from web3 import Web3

FUND_AMOUNT = 300000000


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    price = fund_me.getPrice()
    entrance_fee = fund_me.getEntranceFee()
    convertion_rate = fund_me.getConversionRate(FUND_AMOUNT)
    print("Price: {}, converted: {}".format(price, convertion_rate))
    print(
        "Convertion rate of {} ETH is {}".format(
            Web3.fromWei(FUND_AMOUNT, "ether"), convertion_rate
        )
    )
    print("{} < {}? {}".format(50, convertion_rate, 50 < convertion_rate))
    print("{}".format(fund_me.getConversionRate(1)))
    fund_me.fund({"from": account, "value": FUND_AMOUNT})


def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({"from": account})


def main():
    fund()
    withdraw()
