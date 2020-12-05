::  wallets are compatible with BIPs 44, 49, and 84
::  m / purpose' / coin_type' / account' / change / address_index
::  change can be 0 or 1
::
/-  *btc
/+  bip32
|%
++  max-index  (dec (pow 2 32))
::  chyg: whether account is (non-)change. 0 or 1
::  idx:  an address_index
::  nixt: next indices to generate addresses from (non-change/change)
::  addi: HD path along with UTXOs
::    - used: whether the address has been used
::  wach: map for watched addresses.
::        Membership implies the address is known by outside parties or had prior activity
::  scon: indices to initially scan to in (non-)change accounts
::        defaults to 2^32-1 (i.e. all the addresses, ~4B)
::  wilt: stores xpub; copulates with thousands of indices to form addresses
::
+$  chyg  $?(%0 %1)
+$  idx   @
+$  nixt  (pair idx idx)
+$  addi  [used=? =chyg =idx utxos=(set utxo)]
+$  wach  (map address addi)
+$  scon  $~([max-index max-index] (pair idx idx))
+$  wilt  _bip32
::  walt: wallet datastructure
::  scanned: whether the wallet's addresses have been checked for prior activity
::  scan-to
::  max-gap: maximum number of consec blank addresses before wallet stops scanning
::  confs:   confirmations required (after this is hit for an address, wallet stops refreshing it)
::
+$  walt
  $:  =wilt
      =bipt
      =wach
      =nixt
      scanned=?
      scan-to=scon
      max-gap=@ud
      confs=@ud
  ==
::  input: utxo for a transaction::
::  feyb: fee per byte in sats
::  key:  HD wallet path
::  txi/txo:  input/output for a transaction being built
::  txbu: tx builder -- all information needed to make a transaction for signing 
::
+$  input  [=utxo =chyg =idx]
+$  feyb  sats
+$  key  [=bipt =chyg =idx]
+$  txi  [=utxo ur=(unit rawtx) =key]
+$  txo  [=address value=sats]
+$  txbu  [payee=(unit ship) =vbytes txis=(list txi) txos=(list txo)]
::  scanning addresses and monitoring generated addresses
::  batch: indexes to scan for a given chyg
::  scans: all scans underway (batches)
::
+$  batch  [todo=(set idx) endpoint=idx has-used=?]
+$  scans  (map [xpub chyg] batch)
::
::  %add-wallet: add wallet to state and initiate a scan
::  %address-info: give new data about an address.
::    - used:  address has been seen on the BTC blockchain?
::    - block: the most recent block at the time of this information being retrieved
::  TODO: document
::
+$  action
  $%  [%add-wallet =xpub scan-to=(unit scon) max-gap=(unit @ud) confs=(unit @ud)]
      [%address-info =xpub =chyg =idx utxos=(set utxo) used=? block=@ud]
      [%generate-address =xpub =chyg meta=(unit [payer=ship value=sats])]
      [%generate-txbu =xpub payee=(unit ship) feyb=sats txos=(list txo)]
  ==
::
+$  update
  $%  [%generate-address =address meta=(unit [payer=ship value=sats])]
      [%generate-txbu =xpub =txbu]
      [%scan-done =xpub]
  ==
::  last-block: most recent block this address was checked
::
+$  request
  $%  [%address-info last-block=@ud a=address =xpub =chyg =idx]
  ==
--
