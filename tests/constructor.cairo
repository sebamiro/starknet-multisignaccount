use super::utils::{ deploy, deploy_err, signer_pubkey_1, signer_pubkey_2, signer_pubkey_3 };

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
#[should_panic(expected: ('signers_len/is-zero',))]
fn invalid_no_signers() {
	deploy_err(2, ArrayTrait::new().span());
}

#[test]
#[should_panic(expected: ('signer/zero-signer',))]
fn invalid_zero_signer() {
	let signers = array![0];
	deploy_err(1, signers.span());
}

#[test]
#[should_panic(expected: ('signer/is-already-signer',))]
fn invalid_same_signers_twice() {
	let signers = array![signer_pubkey_1, signer_pubkey_1];
	deploy_err(1, signers.span());
}

#[test]
#[should_panic(expected: ('threshold/too-high',))]
fn invalid_large_threshold() {
	let signers = array![signer_pubkey_1, signer_pubkey_1];
	deploy_err(3, signers.span());
}

#[test]
#[should_panic(expected: ('threshold/is-zero',))]
fn invalid_zero_threshold() {
	let signers = array![signer_pubkey_1, signer_pubkey_1];
	deploy_err(0, signers.span());
}
