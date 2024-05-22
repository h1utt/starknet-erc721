# A simple NFT Collection Factory to create your own NFT Collection!

## Getting Started

### Requirements
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [scarb](https://docs.swmansion.com/scarb/download.html)
- [starkli](https://book.starkli.rs/installation)

### Quickstart
```
git clone https://github.com/h1utt/starknet-erc721.git
cd starknet-erc721
npm i
```

## Deployment to a Testnet or Mainnet

### Setting up your wallet for deploying

- Create a folder to store private data 
```
mkdir -p starkli-wallets/deployer
```

- Create `keystore.json` by pasting your `Private Key` taken from [Argent X](https://www.argent.xyz/argent-x/) or [Braavos](https://braavos.app/) (**Notice that your wallet needs to be funded and deployed to Testnet/Mainnet first!!!**) after running this command
```
starkli signer keystore from-key starkli-wallets/deployer/keystore.json
```

- You'll need an url of the Testnet/Mainnet node you're working with. You can setup one for free from [Blast](https://blastapi.io/)

- Get your <SMART_WALLET_ADDRESS> and run this command to create `account.json` file
```
starkli account fetch <SMART_WALLET_ADDRESS> --output ./starkli-wallets/deployer/account.json --rpc <RPC_URL>
```

- Export `account.json` and `keystore.json`
```
export STARKNET_ACCOUNT=./starkli-wallets/deployer/account.json
export STARKNET_KEYSTORE=./starkli-wallets/deployer/keystore.json
```

### Deploy contract
- Buid your contract
```
scarb build
```

- Declare NFTCollectionFactory contract
```
starkli declare target/dev/nft_collection_NFTCollectionFactory.contract_class.json --rpc <RPC_URL>
```

- You'll notice the contract CLASS_HASH after declaring. Then, deploy NFTCollectionFactory contract
```
starkli deploy <YOUR_FACTORY_CLASS_HASH> <SMART_WALLET_ADDRESS> --rpc <RPC_URL>
```

- Grab the NFTCollectionFactory contract address and paste it under `constructor` function in `MyNFT` contract
```
#[constructor]
    fn constructor(ref self: ContractState, _deploy_data: DeployCallData) {
        let factory_address: ContractAddress =
            YOUR_FACTORY_ADDRESS_GOES_HERE
            .try_into()
            .unwrap(); // Add your factory address here to ensure that only the factory can deploy the NFT Collection
```

- Rebuild your contract
```
scarb build
```


- Declare the MyNFT contract to get the NFT_COLLECTION_CLASS_HASH
```
starkli declare target/dev/nft_collection_MyNFT.contract_class.json --rpc <RPC_URL>
```

- Paste all the necessary variables in `.env`. You can take a look at `.env-example`

- Set the NFT_COLLECTION_CLASS_HASH allowed by running
```
npx ts-node scripts/00-set-class-hash-allowed.ts
```

## Deploy your own NFT Collection!!!

- Config your NFT Colleciton Metadata in `scripts/01-deploy-nft-collection.ts`
```
// Config your NFT Collection Metadata
const name = "YOUR_NFT_COLLECTION_NAME_GOES_HERE!!!";
const symbol = "YOUR_NFT_COLLECTION_SYMBOL_GOES_HERE!!!";
const base_uri = "YOUR_NFT_COLLECTION_URI_GOES_HERE!!!";
```

- Deploy your own NFT Collection!!!
```
npx ts-node scripts/01-deploy-nft-collection.ts
```

