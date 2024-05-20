#[starknet::contract]
mod MyNFT {
    use nft_collection::factory::NFTCollectionFactory::DeployCallData;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721
    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataCamelOnly =
        ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        ERC721_token_id: u256
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    mod Errors {
        const NOT_FACTORY: felt252 = 'ERC721: not factory';
    }

    #[constructor]
    fn constructor(ref self: ContractState, _deploy_data: DeployCallData) {
        let factory_address: ContractAddress =
            0x04622a2e14aeef4593201568a8e99cd4b8d99b651587722d1b1f349e36746c4c
            .try_into()
            .unwrap();
        assert(get_caller_address() == factory_address, Errors::NOT_FACTORY);

        let name = _deploy_data._name;
        let symbol = _deploy_data._symbol;
        let base_uri = _deploy_data._base_uri;

        self.erc721.initializer(name, symbol, base_uri);
    }

    #[external(v0)]
    fn mint(ref self: ContractState) {
        let caller = get_caller_address();

        let token_id = self.ERC721_token_id.read() + 1;

        self.erc721._mint(caller, token_id);

        self.ERC721_token_id.write(token_id);
    }
}
