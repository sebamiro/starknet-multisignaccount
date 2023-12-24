use starknet::account;
use snforge_std::signature;
use snforge_std::signature::interface::Signer;

fn new_tx_info_mock(
	hash: felt252,
	ref signer: signature::StarkCurveKeyPair
) -> snforge_std::TxInfoMock {
	let (r, s) = signer.sign(hash).unwrap();
	let signature = array![signer.public_key, r, s];

	let mut tx_info = snforge_std::TxInfoMockTrait::default();
	tx_info.transaction_hash = Option::Some(hash);
	tx_info.signature = Option::Some(signature.span());
	tx_info
}

fn new_call_mock() -> Array<account::Call> {
    let call = account::Call {
        to: 111.try_into().unwrap(),
        selector: 'fake_endpoint',
        calldata: array![],
    };
    return array![call];
}

fn new_multiple_call_mock() -> Array<account::Call> {
    let call1 = account::Call {
        to: 111.try_into().unwrap(),
        selector: 'fake_endpoint',
        calldata: array![],
    };
    let call2 = account::Call {
        to: 222.try_into().unwrap(),
        selector: 'fake_endpoint',
        calldata: array![],
    };
    return array![call1, call2];
}
