use multisign::multisign::{ TestMultisignDispatcher, TestMultisignDispatcherTrait };
use super::utils::{ deploy, signer_pubkey_1, signer_pubkey_2, signer_pubkey_3 };

const message_hash: felt252 = 424242;

const signer_1_signature_r: felt252 =
    780418022109335103732757207432889561210689172704851180349474175235986529895;
const signer_1_signature_s: felt252 =
    117732574052293722698213953663617651411051623743664517986289794046851647347;

const signer_2_signature_r: felt252 =
    2543572729543774155040746789716602521360190010191061121815852574984983703153;
const signer_2_signature_s: felt252 =
    3047778680024311010844701802416003052323696285920266547201663937333620527443;

#[test]
fn valid_one_signature() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(1, signers.span());

	let signature = array![
		signer_pubkey_1,
		signer_1_signature_r,
		signer_1_signature_s
	];
	assert(
		acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED,
		'Valid signature is not found'
	);
}

#[test]
fn valid_double_signature() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(2, signers.span());

	let signature = array![
		signer_pubkey_1,
		signer_1_signature_r,
		signer_1_signature_s,
		signer_pubkey_2,
		signer_2_signature_r,
		signer_2_signature_s
	];
	assert(
		acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED,
		'Valid signatures are not found'
	);
}

#[test]
#[should_panic(expected: ('signature/not-sorted',))]
fn invalid_signatures_not_sorted() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(2, signers.span());

	let signature = array![
		signer_pubkey_2,
		signer_2_signature_r,
		signer_2_signature_s,
		signer_pubkey_1,
		signer_1_signature_r,
		signer_1_signature_s,
	];
	assert(
		acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED,
		'Valid signatures are not found'
	);
}

#[test]
#[should_panic(expected: ('signature/invalid-len',))]
fn invalid_no_signature() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(2, signers.span());
	let signature: Array<felt252> = ArrayTrait::new();

	acc.is_valid_signature(message_hash, signature);
}

#[test]
#[should_panic(expected: ('signature/invalid-len',))]
fn invalid_too_much_signatures() {
	let signers = array![signer_pubkey_1];
	let acc = deploy(1, signers.span());

	let signature = array![
		signer_pubkey_1,
		signer_1_signature_r,
		signer_1_signature_s,
		signer_pubkey_2,
		signer_2_signature_r,
		signer_2_signature_s,
	];
	acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED;
}

#[test]
#[should_panic(expected: ('signature/not-sorted',))]
fn invalid_same_signature_twice() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	let acc = deploy(2, signers.span());

	let signature = array![
		signer_pubkey_1,
		signer_1_signature_r,
		signer_1_signature_s,
		signer_pubkey_1,
		signer_1_signature_r,
		signer_1_signature_s,
	];
	acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED;
}

#[test]
#[should_panic(expected: ('signer/not-a-signer',))]
fn invalid_missing_signer() {
	let signers = array![signer_pubkey_1];
	let acc = deploy(1, signers.span());

	let signature = array![
		signer_pubkey_2,
		signer_2_signature_r,
		signer_2_signature_s,
	];
	acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED;
}

#[test]
#[should_panic(expected: ('signature/invalid-len',))]
fn invalid_short_signature() {
	let signers = array![signer_pubkey_1];
	let acc = deploy(1, signers.span());

	let signature = array![
		signer_pubkey_1,
	];
	acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED;
}

#[test]
#[should_panic(expected: ('signature/invalid-len',))]
fn invalid_long_signature() {
	let signers = array![signer_pubkey_1];
	let acc = deploy(1, signers.span());

	let signature = array![
		signer_pubkey_1,
		signer_1_signature_r,
		signer_1_signature_s,
		signer_pubkey_2,
		signer_2_signature_r,
		signer_2_signature_s,
		signer_2_signature_s,
	];
	acc.is_valid_signature(message_hash, signature) == starknet::VALIDATED;
}
