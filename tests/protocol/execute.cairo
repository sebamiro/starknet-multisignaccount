use starknet::account;
use multisign::multisign::{ TestMultisignDispatcher, TestMultisignDispatcherTrait };
use snforge_std::signature;
use super::super::utils::{ deploy, signer_pubkey_1, signer_pubkey_2, signer_pubkey_3 };
use super::utils::{ new_tx_info_mock, new_call_mock, new_multiple_call_mock };

#[test]
fn valid_call() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let mut acc = deploy(1, signers.span());

	let call_addr: starknet::ContractAddress = 'caller'.try_into().unwrap();
	let call_func = 'function';
	let ret = 148;

	let call = account::Call {
		to: call_addr,
		selector: selector!("function"),
		calldata: array![]
	};

	let mut tx_info = snforge_std::TxInfoMockTrait::default();

	let addr: starknet::ContractAddress = 0.try_into().unwrap();

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);
	snforge_std::start_mock_call(
		call_addr,
		call_func,
		ret
	);

	let result = acc.__execute__(array![call]);

	snforge_std::stop_mock_call(
		call_addr,
		call_func
	);
	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);

	assert(result.len() > 0, 'Wrong result');
	let result = *(*result.at(0)).at(0);
	assert(result == ret, 'Wrong result');
}

#[test]
fn valid_multiple_call() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let call_addr1: starknet::ContractAddress = 'caller1'.try_into().unwrap();
	let call_addr2: starknet::ContractAddress = 'caller2'.try_into().unwrap();
	let call_func1 = 'function1';
	let ret1 = 111;
	let call_func2 = 'function2';
	let ret2 = 222;

	let call1 = account::Call {
		to: call_addr1,
		selector: selector!("function1"),
		calldata: array![]
	};
	let call2 = account::Call {
		to: call_addr2,
		selector: selector!("function2"),
		calldata: array![]
	};

	let mut tx_info = snforge_std::TxInfoMockTrait::default();

	let addr: starknet::ContractAddress = 0.try_into().unwrap();

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);
	snforge_std::start_mock_call(
		call_addr1,
		call_func1,
		ret1
	);
	snforge_std::start_mock_call(
		call_addr2,
		call_func2,
		ret2
	);

	let result = acc.__execute__(array![call1, call2]);

	snforge_std::stop_mock_call(
		call_addr1,
		call_func1
	);
	snforge_std::stop_mock_call(
		call_addr2,
		call_func2
	);
	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);

	let expected = array![array![ret1].span(), array![ret2].span()];
	assert(result == expected, 'Wrong result');
}

#[test]
#[should_panic(expected: ('execute/no-calls',))]
fn invalid_no_call() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(1, signers.span());
	let addr: starknet::ContractAddress = 0.try_into().unwrap();
	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	acc.__execute__(array![]);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
}

#[test]
#[should_panic(expected: ('caller/non-zero',))]
fn invalid_not_protocol_call() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let mut tx_info = snforge_std::TxInfoMockTrait::default();

	let addr: starknet::ContractAddress = 1.try_into().unwrap();

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);
	acc.__execute__(new_call_mock());
	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
}
