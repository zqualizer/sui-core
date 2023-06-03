module zq_test::deposit{

    use sui::object::{Self, UID,ID};
    use sui::transfer;
    use sui::balance::{Self,Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};



    struct ZqStaking<phantom T> has key{
        id: UID,
        sender:address,
        amount:Balance<T>,
    }

    struct ZqReward<phantom T> has key{
        id: UID,
        staker:address,
        amount:Balance<T>,
        withdraw_amount:u64,
        start_time:u64,
    }

    struct ZqAdminCap has key, store {
        id : UID,
        obj_id : ID,
    }

    const ENO_NO_COLLECTION:u64=0;
    const ENO_STAKING_EXISTS:u64=1;
    const ENO_NO_STAKING:u64=2;
    const ENO_NO_TOKEN_IN_TOKEN_STORE:u64=3;
    const ENO_STOPPED:u64=4;
    const ENO_COINTYPE_MISMATCH:u64=5;
    const ENO_STAKER_MISMATCH:u64=6;
    const ENO_INSUFFICIENT_FUND:u64=7;
    const ENO_INSUFFICIENT_TOKENS:u64=7;


     //Function for creating and modifying staking
    public entry fun create_staking<T,D>(       
        balance:Coin<T>,
        ctx: &mut TxContext,
    )
    {
        let sender = tx_context::sender(ctx);
        let balance = coin::into_balance(balance);
        let id = object::new(ctx);
        let obj_id = object::uid_to_inner(&id);
        let obj = ZqStaking { id, sender , amount:balance };
        transfer::share_object(obj);
        // give the creator admin permissions
        let admin_cap= ZqAdminCap { id: object::new(ctx), obj_id };
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }


    public entry fun stake_token<T>(
        coin: Coin<T>,
        _sender: address,
        _amount : u64,
        ctx: &mut TxContext,
    ){
        let staker = tx_context::sender(ctx);
        let deposited_coin = coin::into_balance(coin);
        let id = object::new(ctx);
        let obj_id = object::uid_to_inner(&id);
        let withdraw_amount=0;
        let start_time=100000;
        let obj = ZqReward { id,staker,amount:deposited_coin,withdraw_amount,start_time };
        transfer::share_object(obj);
        // give the creator admin permissions
        let admin_cap= ZqAdminCap { id: object::new(ctx), obj_id };
        transfer::transfer(admin_cap, tx_context::sender(ctx));
    }

     public entry fun receiver_reward<T,P>(
        staking: &mut ZqStaking<T>,
        reward: &mut ZqReward<P>,
        _sender: address,
        ctx: &mut TxContext,
    )
    {
        let staker = tx_context::sender(ctx);
        let now = 200000;
        let value = balance::value(&reward.amount);
        let payable_amount = ((now-reward.start_time)*value)/86400-reward.withdraw_amount;
        transfer::public_transfer(coin::take(&mut staking.amount, payable_amount, ctx), staker);
        reward.withdraw_amount=reward.withdraw_amount+payable_amount;
    }
    public entry fun unstake_fund<T,P>(
    
        staking: &mut ZqStaking<T>,
        reward: &mut ZqReward<P>,
        _sender: address,
        ctx: &mut TxContext,
    )
    {
        let staker = tx_context::sender(ctx);
        let now = 200000;
        let value = balance::value(&reward.amount);
        let payable_amount = ((now-reward.start_time)*value)/86400-reward.withdraw_amount;
        transfer::public_transfer(coin::take(&mut staking.amount, payable_amount, ctx), staker);
        reward.withdraw_amount= reward.withdraw_amount+payable_amount;
        // transferring all the staked coins to the staker
        transfer::public_transfer(coin::take(&mut reward.amount, value, ctx), staker);
    }    

    

}