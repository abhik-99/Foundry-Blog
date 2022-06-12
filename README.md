# Fun with Foundry and Fuzzing

This repo contains the code for my blog post on how to use Foundry to
1. Develop Contract.
2. Write Tests in Solidity (instead of ChaiJS).
3. Deploy the Contract.

If you wish to follow along I would suggest you browse over to my article published on dev.to . To deploy the contract you need to have Linux or WSL. Make sure to change the environment variables to your required values before following the instructructions below:

1. Run `source ./env.sh` to set the required Environment Variables.
2. Run `forge create --rpc-url $ETH_RPC_URL --constructor-args <CONTRUCTOR ARGUMENTS for your CONTRACT> --private-key $PRIVATE_KEY <CONTRACT NAME> --verify`.

Note: 
1. The `--verify` flag needs to have `ETHERSCAN_API_KEY` variable set. This is done through step 1.
2. The contract name should be without the _.sol_ extension. For eg., if contract name is `Test.sol` and the contract inside it is called `Test`, then you need to pass `Test` in the contract name space in the above command.