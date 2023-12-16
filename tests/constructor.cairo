use super::utils::{ deploy, signer_pubkey_1, signer_pubkey_2, signer_pubkey_3 };

#[test]
fn valid_one_signer() {
	let signers = array![signer_pubkey_1];
	deploy(1, signers.span());
}

#[test]
fn valid_two_signers() {
	let signers = array![signer_pubkey_1, signer_pubkey_2];
	deploy(2, signers.span());
}

#[test]
#[should_panic(expected: ('constructor: Invalid no signers', 'ENTRYPOINT_FAILED'))]
fn invalid_no_signers() {
	deploy(2, ArrayTrait::new().span());
}

#[test]
#[should_panic(expected: ('constructor: Same signer more than once', 'ENTRYPOINT_FAILED'))]
fn invalid_same_signers_twice() {
	let signers = array![signer_pubkey_1, signer_pubkey_1];
	deploy(1, signers.span());
}

#[test]
#[should_panic(expected: ('constructor: Invalid threshold', 'ENTRYPOINT_FAILED'))]
fn invalid_large_threshold() {
	let signers = array![signer_pubkey_1, signer_pubkey_1];
	deploy(3, signers.span());
}

#[test]
#[should_panic(expected: ('constructor: Invalid threshold', 'ENTRYPOINT_FAILED'))]
fn invalid_zero_threshold() {
	let signers = array![signer_pubkey_1, signer_pubkey_1];
	deploy(0, signers.span());
}
