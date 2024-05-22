import { Account, Contract, RpcProvider } from "starknet";
import "dotenv/config";

const RPC_URL = process.env.RPC_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const ACCOUNT_ADDRESS = process.env.ACCOUNT_ADDRESS || "";
const FACTORY_CONTRACT = process.env.FACTORY_CONTRACT_ADDRESS || "";
const CLASS_HASH = process.env.NFT_COLLECTION_CLASS_HASH || "";

async function main() {
  // Initialize provider
  const provider = new RpcProvider({
    nodeUrl: RPC_URL,
  });

  // Initialize existing account
  const privateKey = PRIVATE_KEY;
  const accountAddress = ACCOUNT_ADDRESS;

  // Cairo 1
  const account = new Account(provider, accountAddress, privateKey);
  console.log(account);

  // Initialize deployed contract
  const factoryContract = FACTORY_CONTRACT;
  const { abi: contractAbi } = await provider.getClassAt(factoryContract); // Read ABI
  if (contractAbi == undefined) {
    throw new Error("No ABI.");
  }

  // Connect the contract
  const contract = new Contract(contractAbi, factoryContract, provider);

  // Connect account with the contract
  contract.connect(account);

  console.log("Invoke Tx...");

  const class_hash = CLASS_HASH;

  // Config your NFT Collection Metadata
  const name = "YOUR_NFT_COLLECTION_NAME_GOES_HERE!!!";
  const symbol = "YOUR_NFT_COLLECTION_SYMBOL_GOES_HERE!!!";
  const base_uri = "YOUR_NFT_COLLECTION_URI_GOES_HERE!!!";

  const myCall = contract.populate("deploy_new_nft_collection", [
    class_hash,
    name,
    symbol,
    base_uri,
  ]);

  const call = await account.execute(myCall, undefined, {
    maxFee: 1000000000000000000,
  });

  console.log("Successfully deployed new NFT Collection contract!");
  console.log("Tx Hash:", call.transaction_hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
