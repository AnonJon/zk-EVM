-include .env

install:
	forge install foundry-rs/forge-std --no-commit

tests:
	forge test -vvvv