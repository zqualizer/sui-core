module zq_test::zq_nft {

    use sui::url::{Self, Url};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    use sui::transfer;


    struct ZqNFT has key, store{
        id: UID,
        token: address,
        amount: u64,
        url: Url,
    }

    struct MintNFTEvent has copy, drop {
        object_id : ID,
        creator: address
    }

    /// Create a new devnet_nft
    public entry fun mint(
        token: address,
        amount: u64,
        url: vector<u8>,
        ctx: &mut TxContext
    ) {
        let nft = ZqNFT {
            id: object::new(ctx),
            token : token,
            amount: amount,
            url: url::new_unsafe_from_bytes(url)
        };
        let sender = tx_context::sender(ctx);
        event::emit(MintNFTEvent {
            object_id: object::uid_to_inner(&nft.id),
            creator: sender
        });
        transfer::public_transfer(nft, sender);
    }

}