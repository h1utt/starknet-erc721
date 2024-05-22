import { Account, Contract, RpcProvider, CallData } from "starknet";
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
  const account = new Account(provider, accountAddress, privateKey, "1");
  console.log(account);

  const factoryContract = FACTORY_CONTRACT;
  const classhash = CLASS_HASH;
  const { abi: contractAbi } = await provider.getClassAt(factoryContract); // Read ABI
  if (contractAbi == undefined) {
    throw new Error("No ABI.");
  }

  const contract = new Contract(contractAbi, factoryContract, provider);
  contract.connect(account);

  const multiCall = await account.execute([
    {
      contractAddress: factoryContract,
      entrypoint: "set_class_hash_allowed",
      calldata: CallData.compile({
        _class_hash: classhash,
        is_allowed: true,
      }),
    },
  ]);
  console.log("Successfully!");
  console.log("Tx Hash:", multiCall.transaction_hash);
}

main();
