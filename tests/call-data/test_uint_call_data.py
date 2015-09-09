from populus.utils import wait_for_txn


deploy_max_wait = 15
deploy_max_first_block_wait = 180

geth_max_wait = 45


def test_registering_uint(geth_node, deployed_contracts):
    registry = deployed_contracts.DataRegistry
    client_contract = deployed_contracts.TestDataRegistry

    assert client_contract.wasSuccessful.call() == 0

    txn_hash = client_contract.registerUInt.sendTransaction(registry._meta.address, 3, gas=3512508359)
    wait_for_txn(client_contract._meta.rpc_client, txn_hash)

    assert client_contract.wasSuccessful.call() == 1

    data_hash = registry.getLastDataHash.call()
    assert data_hash is not None
