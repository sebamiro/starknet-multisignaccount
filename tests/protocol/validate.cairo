use multisign::multisign::{ TestMultisignDispatcher, TestMultisignDispatcherTrait };
use snforge_std::signature;
use super::super::utils::{ deploy, signer_pubkey_1, signer_pubkey_2, signer_pubkey_3 };
use super::utils::{ new_tx_info_mock, new_call_mock, new_multiple_call_mock };

#[test]
fn valid_tx() {
	let mut signer = signature::StarkCurveKeyPairTrait::from_private_key(signer_pubkey_1);
	let signers = array![signer.public_key, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let tx_info = new_tx_info_mock(123, ref signer);
	let addr: starknet::ContractAddress = 0.try_into().unwrap();

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);

	acc.__validate__(new_call_mock());

	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
}

#[test]
fn valid_tx_multiple_calls() {
	let mut signer = signature::StarkCurveKeyPairTrait::from_private_key(signer_pubkey_1);
	let signers = array![signer.public_key, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let tx_info = new_tx_info_mock(123, ref signer);
	let addr: starknet::ContractAddress = 0.try_into().unwrap();

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);

	acc.__validate__(new_multiple_call_mock());

	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
}

#[test]
#[should_panic(expected: ('caller/non-zero',))]
fn invalid_not_protocol_call() {
	let mut signer = signature::StarkCurveKeyPairTrait::from_private_key(signer_pubkey_1);
	let signers = array![signer.public_key, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let tx_info = new_tx_info_mock(123, ref signer);
	let addr: starknet::ContractAddress = 1.try_into().unwrap();

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);

	acc.__validate__(new_call_mock());

	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
}

#[test]
#[should_panic(expected: ('call/call-to-self',))]
fn invalid_call_to_the_account() {
	let mut signer = signature::StarkCurveKeyPairTrait::from_private_key(signer_pubkey_1);
	let signers = array![signer.public_key, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let tx_info = new_tx_info_mock(123, ref signer);
	let addr: starknet::ContractAddress = 0.try_into().unwrap();

    let call = starknet::account::Call {
        to: acc.contract_address,
        selector: 'fake_endpoint',
        calldata: array![],
    };

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);

	acc.__validate__(array![call]);

	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
}

#[test]
#[should_panic(expected: ('validate/no-calls',))]
fn invalid_no_calls() {
	let mut signer = signature::StarkCurveKeyPairTrait::from_private_key(signer_pubkey_1);
	let signers = array![signer.public_key, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let tx_info = new_tx_info_mock(123, ref signer);
	let addr: starknet::ContractAddress = 0.try_into().unwrap();

	snforge_std::start_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
		addr
	);
	snforge_std::start_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
		tx_info
	);

	acc.__validate__(array![]);

	snforge_std::stop_spoof(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
	snforge_std::stop_prank(
		snforge_std::CheatTarget::One(acc.contract_address),
	);
}

