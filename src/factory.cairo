#[starknet::contract]
mod NFTCollectionFactory {
    use starknet::ContractAddress;
    use starknet::class_hash::ClassHash;
    use starknet::get_caller_address;
    use poseidon::poseidon_hash_span;

    #[derive(Drop, Serde)]
    struct DeployCallData {
        _id: felt252,
        _name: ByteArray,
        _symbol: ByteArray,
        _base_uri: ByteArray
    }

    mod Errors {
        const ERROR_NOT_OWNER: felt252 = 'factory: not owner';
        const ERROR_UNWHITELISTED_CLASS_HASH: felt252 = 'factory: unwlt class hash';
    }

    #[storage]
    struct Storage {
        id: u256,
        owner: ContractAddress,
        collection_list: LegacyMap<ContractAddress, bool>,
        class_hash_allowed: LegacyMap<ClassHash, bool>
    }

    #[derive(Drop, starknet::Event)]
    struct EventNewERC721NFTCollection {
        contract_address: ContractAddress,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray
    }

    #[derive(Drop, starknet::Event)]
    struct EventClassHashUpdated {
        class_hash: ClassHash,
        allowed: bool
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        EventNewERC721NFTCollection: EventNewERC721NFTCollection,
        EventClassHashUpdated: EventClassHashUpdated
    }

    #[constructor]
    fn constructor(ref self: ContractState, _owner: ContractAddress) {
        self.owner.write(_owner);
    }

    #[external(v0)]
    fn deploy_new_nft_collection(
        ref self: ContractState,
        class_hash: ClassHash,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray
    ) -> ContractAddress {
        assert(self.class_hash_allowed.read(class_hash), Errors::ERROR_UNWHITELISTED_CLASS_HASH);

        let name_event = name.clone();
        let symbol_event = symbol.clone();
        let base_uri_event = base_uri.clone();

        let mut hash_data: Array<felt252> = ArrayTrait::new();
        let mut calldata = array![];
        let deploy_data = DeployCallData {
            _id: (self.id.read() + 1).try_into().unwrap(),
            _name: name,
            _symbol: symbol,
            _base_uri: base_uri
        };

        Serde::serialize(@deploy_data, ref hash_data);
        let salt = poseidon_hash_span(hash_data.span());
        Serde::serialize(@deploy_data, ref calldata);

        // Increase id
        self.id.write(self.id.read() + 1);

        // Deploy new contract instance
        let deployFromZero: bool = false;
        let (contract_address, _) = starknet::deploy_syscall(
            class_hash, salt, calldata.span(), deployFromZero
        )
            .unwrap();

        // Write to collection list
        self.collection_list.write(contract_address, true);

        // Emit event
        self
            .emit(
                EventNewERC721NFTCollection {
                    contract_address,
                    name: name_event,
                    symbol: symbol_event,
                    base_uri: base_uri_event
                }
            );

        contract_address
    }

    #[external(v0)]
    fn set_class_hash_allowed(ref self: ContractState, class_hash: ClassHash, allowed: bool) {
        let caller = get_caller_address();
        assert(caller == self.owner.read(), Errors::ERROR_NOT_OWNER);

        // Write to storage
        self.class_hash_allowed.write(class_hash, allowed);

        // Emit event
        self.emit(EventClassHashUpdated { class_hash: class_hash, allowed: allowed });
    }
}
