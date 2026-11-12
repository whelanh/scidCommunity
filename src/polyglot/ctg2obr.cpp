// SPDX-FileCopyrightText: 2023 Ali Polatel <alip@chesswob.org>
// SPDX-FileCopyrightText: 2007 Steinar H. Gunderson <steinar+remoteglot@gunderson.no>
// SPDX-FileCopyrightText: 2026 TBergh98
// SPDX-License-Identifier: GPL-3.0-or-later
//
// ctg2obr: convert a ChessBase CTG book to OpenBook Rich (.obr).
//
// From tools/ctg2obr.cpp of https://github.com/TBergh98/openbook-rich
// (commit 999879f). Changes for Scid: main() became ctg2obr() (see
// ctg2obr.h), with progress reports and cancellation; paths are UTF-8, as
// Tcl passes them; the output is written to a temporary file and renamed, so
// a failed conversion leaves no partial book; everything else is unchanged.
//
// C++ port of the Python reference pipeline ctgwalk.py + gen_aliases.py +
// build_obr.py. The output is byte-identical to it, except the metadata
// fields "generator" and "created" (and the header field meta_len, which
// follows from them). tools/compare_obr.py checks this.
//
// This file is GPL-3.0-or-later because of the move table below. Scid is
// GPL-2.0-or-later, so a Scid binary built with it is distributed under the
// GPL version 3.
//
// The move table comes from jja 0.9.1 (https://git.sr.ht/~alip/jja,
// Copyright (c) 2023 Ali Polatel, GPL-3.0-or-later), see ctg_movetable.py.
// The position encoding, Huffman codes and TBL2 follow Steinar H. Gunderson's
// CTG specification and remoteglot, as implemented in jja. The Polyglot
// Zobrist keys are the public Polyglot random array.
//
#include "ctg2obr.h"

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <filesystem>
#include <stdexcept>
#include <string>
#include <vector>

#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#else
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

namespace {

struct MoveCode { char piece; int8_t num, fwd, right; };

static const uint64_t ZOBRIST[781] = {
    0x9d39247e33776d41ULL, 0x2af7398005aaa5c7ULL, 0x44db015024623547ULL, 0x9c15f73e62a76ae2ULL,
    0x75834465489c0c89ULL, 0x3290ac3a203001bfULL, 0x0fbbad1f61042279ULL, 0xe83a908ff2fb60caULL,
    0x0d7e765d58755c10ULL, 0x1a083822ceafe02dULL, 0x9605d5f0e25ec3b0ULL, 0xd021ff5cd13a2ed5ULL,
    0x40bdf15d4a672e32ULL, 0x011355146fd56395ULL, 0x5db4832046f3d9e5ULL, 0x239f8b2d7ff719ccULL,
    0x05d1a1ae85b49aa1ULL, 0x679f848f6e8fc971ULL, 0x7449bbff801fed0bULL, 0x7d11cdb1c3b7adf0ULL,
    0x82c7709e781eb7ccULL, 0xf3218f1c9510786cULL, 0x331478f3af51bbe6ULL, 0x4bb38de5e7219443ULL,
    0xaa649c6ebcfd50fcULL, 0x8dbd98a352afd40bULL, 0x87d2074b81d79217ULL, 0x19f3c751d3e92ae1ULL,
    0xb4ab30f062b19abfULL, 0x7b0500ac42047ac4ULL, 0xc9452ca81a09d85dULL, 0x24aa6c514da27500ULL,
    0x4c9f34427501b447ULL, 0x14a68fd73c910841ULL, 0xa71b9b83461cbd93ULL, 0x03488b95b0f1850fULL,
    0x637b2b34ff93c040ULL, 0x09d1bc9a3dd90a94ULL, 0x3575668334a1dd3bULL, 0x735e2b97a4c45a23ULL,
    0x18727070f1bd400bULL, 0x1fcbacd259bf02e7ULL, 0xd310a7c2ce9b6555ULL, 0xbf983fe0fe5d8244ULL,
    0x9f74d14f7454a824ULL, 0x51ebdc4ab9ba3035ULL, 0x5c82c505db9ab0faULL, 0xfcf7fe8a3430b241ULL,
    0x3253a729b9ba3ddeULL, 0x8c74c368081b3075ULL, 0xb9bc6c87167c33e7ULL, 0x7ef48f2b83024e20ULL,
    0x11d505d4c351bd7fULL, 0x6568fca92c76a243ULL, 0x4de0b0f40f32a7b8ULL, 0x96d693460cc37e5dULL,
    0x42e240cb63689f2fULL, 0x6d2bdcdae2919661ULL, 0x42880b0236e4d951ULL, 0x5f0f4a5898171bb6ULL,
    0x39f890f579f92f88ULL, 0x93c5b5f47356388bULL, 0x63dc359d8d231b78ULL, 0xec16ca8aea98ad76ULL,
    0x5355f900c2a82dc7ULL, 0x07fb9f855a997142ULL, 0x5093417aa8a7ed5eULL, 0x7bcbc38da25a7f3cULL,
    0x19fc8a768cf4b6d4ULL, 0x637a7780decfc0d9ULL, 0x8249a47aee0e41f7ULL, 0x79ad695501e7d1e8ULL,
    0x14acbaf4777d5776ULL, 0xf145b6beccdea195ULL, 0xdabf2ac8201752fcULL, 0x24c3c94df9c8d3f6ULL,
    0xbb6e2924f03912eaULL, 0x0ce26c0b95c980d9ULL, 0xa49cd132bfbf7cc4ULL, 0xe99d662af4243939ULL,
    0x27e6ad7891165c3fULL, 0x8535f040b9744ff1ULL, 0x54b3f4fa5f40d873ULL, 0x72b12c32127fed2bULL,
    0xee954d3c7b411f47ULL, 0x9a85ac909a24eaa1ULL, 0x70ac4cd9f04f21f5ULL, 0xf9b89d3e99a075c2ULL,
    0x87b3e2b2b5c907b1ULL, 0xa366e5b8c54f48b8ULL, 0xae4a9346cc3f7cf2ULL, 0x1920c04d47267bbdULL,
    0x87bf02c6b49e2ae9ULL, 0x092237ac237f3859ULL, 0xff07f64ef8ed14d0ULL, 0x8de8dca9f03cc54eULL,
    0x9c1633264db49c89ULL, 0xb3f22c3d0b0b38edULL, 0x390e5fb44d01144bULL, 0x5bfea5b4712768e9ULL,
    0x1e1032911fa78984ULL, 0x9a74acb964e78cb3ULL, 0x4f80f7a035dafb04ULL, 0x6304d09a0b3738c4ULL,
    0x2171e64683023a08ULL, 0x5b9b63eb9ceff80cULL, 0x506aacf489889342ULL, 0x1881afc9a3a701d6ULL,
    0x6503080440750644ULL, 0xdfd395339cdbf4a7ULL, 0xef927dbcf00c20f2ULL, 0x7b32f7d1e03680ecULL,
    0xb9fd7620e7316243ULL, 0x05a7e8a57db91b77ULL, 0xb5889c6e15630a75ULL, 0x4a750a09ce9573f7ULL,
    0xcf464cec899a2f8aULL, 0xf538639ce705b824ULL, 0x3c79a0ff5580ef7fULL, 0xede6c87f8477609dULL,
    0x799e81f05bc93f31ULL, 0x86536b8cf3428a8cULL, 0x97d7374c60087b73ULL, 0xa246637cff328532ULL,
    0x043fcae60cc0eba0ULL, 0x920e449535dd359eULL, 0x70eb093b15b290ccULL, 0x73a1921916591cbdULL,
    0x56436c9fe1a1aa8dULL, 0xefac4b70633b8f81ULL, 0xbb215798d45df7afULL, 0x45f20042f24f1768ULL,
    0x930f80f4e8eb7462ULL, 0xff6712ffcfd75ea1ULL, 0xae623fd67468aa70ULL, 0xdd2c5bc84bc8d8fcULL,
    0x7eed120d54cf2dd9ULL, 0x22fe545401165f1cULL, 0xc91800e98fb99929ULL, 0x808bd68e6ac10365ULL,
    0xdec468145b7605f6ULL, 0x1bede3a3aef53302ULL, 0x43539603d6c55602ULL, 0xaa969b5c691ccb7aULL,
    0xa87832d392efee56ULL, 0x65942c7b3c7e11aeULL, 0xded2d633cad004f6ULL, 0x21f08570f420e565ULL,
    0xb415938d7da94e3cULL, 0x91b859e59ecb6350ULL, 0x10cff333e0ed804aULL, 0x28aed140be0bb7ddULL,
    0xc5cc1d89724fa456ULL, 0x5648f680f11a2741ULL, 0x2d255069f0b7dab3ULL, 0x9bc5a38ef729abd4ULL,
    0xef2f054308f6a2bcULL, 0xaf2042f5cc5c2858ULL, 0x480412bab7f5be2aULL, 0xaef3af4a563dfe43ULL,
    0x19afe59ae451497fULL, 0x52593803dff1e840ULL, 0xf4f076e65f2ce6f0ULL, 0x11379625747d5af3ULL,
    0xbce5d2248682c115ULL, 0x9da4243de836994fULL, 0x066f70b33fe09017ULL, 0x4dc4de189b671a1cULL,
    0x51039ab7712457c3ULL, 0xc07a3f80c31fb4b4ULL, 0xb46ee9c5e64a6e7cULL, 0xb3819a42abe61c87ULL,
    0x21a007933a522a20ULL, 0x2df16f761598aa4fULL, 0x763c4a1371b368fdULL, 0xf793c46702e086a0ULL,
    0xd7288e012aeb8d31ULL, 0xde336a2a4bc1c44bULL, 0x0bf692b38d079f23ULL, 0x2c604a7a177326b3ULL,
    0x4850e73e03eb6064ULL, 0xcfc447f1e53c8e1bULL, 0xb05ca3f564268d99ULL, 0x9ae182c8bc9474e8ULL,
    0xa4fc4bd4fc5558caULL, 0xe755178d58fc4e76ULL, 0x69b97db1a4c03dfeULL, 0xf9b5b7c4acc67c96ULL,
    0xfc6a82d64b8655fbULL, 0x9c684cb6c4d24417ULL, 0x8ec97d2917456ed0ULL, 0x6703df9d2924e97eULL,
    0xc547f57e42a7444eULL, 0x78e37644e7cad29eULL, 0xfe9a44e9362f05faULL, 0x08bd35cc38336615ULL,
    0x9315e5eb3a129aceULL, 0x94061b871e04df75ULL, 0xdf1d9f9d784ba010ULL, 0x3bba57b68871b59dULL,
    0xd2b7adeeded1f73fULL, 0xf7a255d83bc373f8ULL, 0xd7f4f2448c0ceb81ULL, 0xd95be88cd210ffa7ULL,
    0x336f52f8ff4728e7ULL, 0xa74049dac312ac71ULL, 0xa2f61bb6e437fdb5ULL, 0x4f2a5cb07f6a35b3ULL,
    0x87d380bda5bf7859ULL, 0x16b9f7e06c453a21ULL, 0x7ba2484c8a0fd54eULL, 0xf3a678cad9a2e38cULL,
    0x39b0bf7dde437ba2ULL, 0xfcaf55c1bf8a4424ULL, 0x18fcf680573fa594ULL, 0x4c0563b89f495ac3ULL,
    0x40e087931a00930dULL, 0x8cffa9412eb642c1ULL, 0x68ca39053261169fULL, 0x7a1ee967d27579e2ULL,
    0x9d1d60e5076f5b6fULL, 0x3810e399b6f65ba2ULL, 0x32095b6d4ab5f9b1ULL, 0x35cab62109dd038aULL,
    0xa90b24499fcfafb1ULL, 0x77a225a07cc2c6bdULL, 0x513e5e634c70e331ULL, 0x4361c0ca3f692f12ULL,
    0xd941aca44b20a45bULL, 0x528f7c8602c5807bULL, 0x52ab92beb9613989ULL, 0x9d1dfa2efc557f73ULL,
    0x722ff175f572c348ULL, 0x1d1260a51107fe97ULL, 0x7a249a57ec0c9ba2ULL, 0x04208fe9e8f7f2d6ULL,
    0x5a110c6058b920a0ULL, 0x0cd9a497658a5698ULL, 0x56fd23c8f9715a4cULL, 0x284c847b9d887aaeULL,
    0x04feabfbbdb619cbULL, 0x742e1e651c60ba83ULL, 0x9a9632e65904ad3cULL, 0x881b82a13b51b9e2ULL,
    0x506e6744cd974924ULL, 0xb0183db56ffc6a79ULL, 0x0ed9b915c66ed37eULL, 0x5e11e86d5873d484ULL,
    0xf678647e3519ac6eULL, 0x1b85d488d0f20cc5ULL, 0xdab9fe6525d89021ULL, 0x0d151d86adb73615ULL,
    0xa865a54edcc0f019ULL, 0x93c42566aef98ffbULL, 0x99e7afeabe000731ULL, 0x48cbff086ddf285aULL,
    0x7f9b6af1ebf78bafULL, 0x58627e1a149bba21ULL, 0x2cd16e2abd791e33ULL, 0xd363eff5f0977996ULL,
    0x0ce2a38c344a6eedULL, 0x1a804aadb9cfa741ULL, 0x907f30421d78c5deULL, 0x501f65edb3034d07ULL,
    0x37624ae5a48fa6e9ULL, 0x957baf61700cff4eULL, 0x3a6c27934e31188aULL, 0xd49503536abca345ULL,
    0x088e049589c432e0ULL, 0xf943aee7febf21b8ULL, 0x6c3b8e3e336139d3ULL, 0x364f6ffa464ee52eULL,
    0xd60f6dcedc314222ULL, 0x56963b0dca418fc0ULL, 0x16f50edf91e513afULL, 0xef1955914b609f93ULL,
    0x565601c0364e3228ULL, 0xecb53939887e8175ULL, 0xbac7a9a18531294bULL, 0xb344c470397bba52ULL,
    0x65d34954daf3cebdULL, 0xb4b81b3fa97511e2ULL, 0xb422061193d6f6a7ULL, 0x071582401c38434dULL,
    0x7a13f18bbedc4ff5ULL, 0xbc4097b116c524d2ULL, 0x59b97885e2f2ea28ULL, 0x99170a5dc3115544ULL,
    0x6f423357e7c6a9f9ULL, 0x325928ee6e6f8794ULL, 0xd0e4366228b03343ULL, 0x565c31f7de89ea27ULL,
    0x30f5611484119414ULL, 0xd873db391292ed4fULL, 0x7bd94e1d8e17debcULL, 0xc7d9f16864a76e94ULL,
    0x947ae053ee56e63cULL, 0xc8c93882f9475f5fULL, 0x3a9bf55ba91f81caULL, 0xd9a11fbb3d9808e4ULL,
    0x0fd22063edc29fcaULL, 0xb3f256d8aca0b0b9ULL, 0xb03031a8b4516e84ULL, 0x35dd37d5871448afULL,
    0xe9f6082b05542e4eULL, 0xebfafa33d7254b59ULL, 0x9255abb50d532280ULL, 0xb9ab4ce57f2d34f3ULL,
    0x693501d628297551ULL, 0xc62c58f97dd949bfULL, 0xcd454f8f19c5126aULL, 0xbbe83f4ecc2bdecbULL,
    0xdc842b7e2819e230ULL, 0xba89142e007503b8ULL, 0xa3bc941d0a5061cbULL, 0xe9f6760e32cd8021ULL,
    0x09c7e552bc76492fULL, 0x852f54934da55cc9ULL, 0x8107fccf064fcf56ULL, 0x098954d51fff6580ULL,
    0x23b70edb1955c4bfULL, 0xc330de426430f69dULL, 0x4715ed43e8a45c0aULL, 0xa8d7e4dab780a08dULL,
    0x0572b974f03ce0bbULL, 0xb57d2e985e1419c7ULL, 0xe8d9ecbe2cf3d73fULL, 0x2fe4b17170e59750ULL,
    0x11317ba87905e790ULL, 0x7fbf21ec8a1f45ecULL, 0x1725cabfcb045b00ULL, 0x964e915cd5e2b207ULL,
    0x3e2b8bcbf016d66dULL, 0xbe7444e39328a0acULL, 0xf85b2b4fbcde44b7ULL, 0x49353fea39ba63b1ULL,
    0x1dd01aafcd53486aULL, 0x1fca8a92fd719f85ULL, 0xfc7c95d827357afaULL, 0x18a6a990c8b35ebdULL,
    0xcccb7005c6b9c28dULL, 0x3bdbb92c43b17f26ULL, 0xaa70b5b4f89695a2ULL, 0xe94c39a54a98307fULL,
    0xb7a0b174cff6f36eULL, 0xd4dba84729af48adULL, 0x2e18bc1ad9704a68ULL, 0x2de0966daf2f8b1cULL,
    0xb9c11d5b1e43a07eULL, 0x64972d68dee33360ULL, 0x94628d38d0c20584ULL, 0xdbc0d2b6ab90a559ULL,
    0xd2733c4335c6a72fULL, 0x7e75d99d94a70f4dULL, 0x6ced1983376fa72bULL, 0x97fcaacbf030bc24ULL,
    0x7b77497b32503b12ULL, 0x8547eddfb81ccb94ULL, 0x79999cdff70902cbULL, 0xcffe1939438e9b24ULL,
    0x829626e3892d95d7ULL, 0x92fae24291f2b3f1ULL, 0x63e22c147b9c3403ULL, 0xc678b6d860284a1cULL,
    0x5873888850659ae7ULL, 0x0981dcd296a8736dULL, 0x9f65789a6509a440ULL, 0x9ff38fed72e9052fULL,
    0xe479ee5b9930578cULL, 0xe7f28ecd2d49eecdULL, 0x56c074a581ea17feULL, 0x5544f7d774b14aefULL,
    0x7b3f0195fc6f290fULL, 0x12153635b2c0cf57ULL, 0x7f5126dbba5e0ca7ULL, 0x7a76956c3eafb413ULL,
    0x3d5774a11d31ab39ULL, 0x8a1b083821f40cb4ULL, 0x7b4a38e32537df62ULL, 0x950113646d1d6e03ULL,
    0x4da8979a0041e8a9ULL, 0x3bc36e078f7515d7ULL, 0x5d0a12f27ad310d1ULL, 0x7f9d1a2e1ebe1327ULL,
    0xda3a361b1c5157b1ULL, 0xdcdd7d20903d0c25ULL, 0x36833336d068f707ULL, 0xce68341f79893389ULL,
    0xab9090168dd05f34ULL, 0x43954b3252dc25e5ULL, 0xb438c2b67f98e5e9ULL, 0x10dcd78e3851a492ULL,
    0xdbc27ab5447822bfULL, 0x9b3cdb65f82ca382ULL, 0xb67b7896167b4c84ULL, 0xbfced1b0048eac50ULL,
    0xa9119b60369ffebdULL, 0x1fff7ac80904bf45ULL, 0xac12fb171817eee7ULL, 0xaf08da9177dda93dULL,
    0x1b0cab936e65c744ULL, 0xb559eb1d04e5e932ULL, 0xc37b45b3f8d6f2baULL, 0xc3a9dc228caac9e9ULL,
    0xf3b8b6675a6507ffULL, 0x9fc477de4ed681daULL, 0x67378d8eccef96cbULL, 0x6dd856d94d259236ULL,
    0xa319ce15b0b4db31ULL, 0x073973751f12dd5eULL, 0x8a8e849eb32781a5ULL, 0xe1925c71285279f5ULL,
    0x74c04bf1790c0efeULL, 0x4dda48153c94938aULL, 0x9d266d6a1cc0542cULL, 0x7440fb816508c4feULL,
    0x13328503df48229fULL, 0xd6bf7baee43cac40ULL, 0x4838d65f6ef6748fULL, 0x1e152328f3318deaULL,
    0x8f8419a348f296bfULL, 0x72c8834a5957b511ULL, 0xd7a023a73260b45cULL, 0x94ebc8abcfb56daeULL,
    0x9fc10d0f989993e0ULL, 0xde68a2355b93cae6ULL, 0xa44cfe79ae538bbeULL, 0x9d1d84fcce371425ULL,
    0x51d2b1ab2ddfb636ULL, 0x2fd7e4b9e72cd38cULL, 0x65ca5b96b7552210ULL, 0xdd69a0d8ab3b546dULL,
    0x604d51b25fbf70e2ULL, 0x73aa8a564fb7ac9eULL, 0x1a8c1e992b941148ULL, 0xaac40a2703d9bea0ULL,
    0x764dbeae7fa4f3a6ULL, 0x1e99b96e70a9be8bULL, 0x2c5e9deb57ef4743ULL, 0x3a938fee32d29981ULL,
    0x26e6db8ffdf5adfeULL, 0x469356c504ec9f9dULL, 0xc8763c5b08d1908cULL, 0x3f6c6af859d80055ULL,
    0x7f7cc39420a3a545ULL, 0x9bfb227ebdf4c5ceULL, 0x89039d79d6fc5c5cULL, 0x8fe88b57305e2ab6ULL,
    0xa09e8c8c35ab96deULL, 0xfa7e393983325753ULL, 0xd6b6d0ecc617c699ULL, 0xdfea21ea9e7557e3ULL,
    0xb67c1fa481680af8ULL, 0xca1e3785a9e724e5ULL, 0x1cfc8bed0d681639ULL, 0xd18d8549d140caeaULL,
    0x4ed0fe7e9dc91335ULL, 0xe4dbf0634473f5d2ULL, 0x1761f93a44d5aefeULL, 0x53898e4c3910da55ULL,
    0x734de8181f6ec39aULL, 0x2680b122baa28d97ULL, 0x298af231c85bafabULL, 0x7983eed3740847d5ULL,
    0x66c1a2a1a60cd889ULL, 0x9e17e49642a3e4c1ULL, 0xedb454e7badc0805ULL, 0x50b704cab602c329ULL,
    0x4cc317fb9cddd023ULL, 0x66b4835d9eafea22ULL, 0x219b97e26ffc81bdULL, 0x261e4e4c0a333a9dULL,
    0x1fe2cca76517db90ULL, 0xd7504dfa8816edbbULL, 0xb9571fa04dc089c8ULL, 0x1ddc0325259b27deULL,
    0xcf3f4688801eb9aaULL, 0xf4f5d05c10cab243ULL, 0x38b6525c21a42b0eULL, 0x36f60e2ba4fa6800ULL,
    0xeb3593803173e0ceULL, 0x9c4cd6257c5a3603ULL, 0xaf0c317d32adaa8aULL, 0x258e5a80c7204c4bULL,
    0x8b889d624d44885dULL, 0xf4d14597e660f855ULL, 0xd4347f66ec8941c3ULL, 0xe699ed85b0dfb40dULL,
    0x2472f6207c2d0484ULL, 0xc2a1e7b5b459aeb5ULL, 0xab4f6451cc1d45ecULL, 0x63767572ae3d6174ULL,
    0xa59e0bd101731a28ULL, 0x116d0016cb948f09ULL, 0x2cf9c8ca052f6e9fULL, 0x0b090a7560a968e3ULL,
    0xabeeddb2dde06ff1ULL, 0x58efc10b06a2068dULL, 0xc6e57a78fbd986e0ULL, 0x2eab8ca63ce802d7ULL,
    0x14a195640116f336ULL, 0x7c0828dd624ec390ULL, 0xd74bbe77e6116ac7ULL, 0x804456af10f5fb53ULL,
    0xebe9ea2adf4321c7ULL, 0x03219a39ee587a30ULL, 0x49787fef17af9924ULL, 0xa1e9300cd8520548ULL,
    0x5b45e522e4b1b4efULL, 0xb49c3b3995091a36ULL, 0xd4490ad526f14431ULL, 0x12a8f216af9418c2ULL,
    0x001f837cc7350524ULL, 0x1877b51e57a764d5ULL, 0xa2853b80f17f58eeULL, 0x993e1de72d36d310ULL,
    0xb3598080ce64a656ULL, 0x252f59cf0d9f04bbULL, 0xd23c8e176d113600ULL, 0x1bda0492e7e4586eULL,
    0x21e0bd5026c619bfULL, 0x3b097adaf088f94eULL, 0x8d14dedb30be846eULL, 0xf95cffa23af5f6f4ULL,
    0x3871700761b3f743ULL, 0xca672b91e9e4fa16ULL, 0x64c8e531bff53b55ULL, 0x241260ed4ad1e87dULL,
    0x106c09b972d2e822ULL, 0x7fba195410e5ca30ULL, 0x7884d9bc6cb569d8ULL, 0x0647dfedcd894a29ULL,
    0x63573ff03e224774ULL, 0x4fc8e9560f91b123ULL, 0x1db956e450275779ULL, 0xb8d91274b9e9d4fbULL,
    0xa2ebee47e2fbfce1ULL, 0xd9f1f30ccd97fb09ULL, 0xefed53d75fd64e6bULL, 0x2e6d02c36017f67fULL,
    0xa9aa4d20db084e9bULL, 0xb64be8d8b25396c1ULL, 0x70cb6af7c2d5bcf0ULL, 0x98f076a4f7a2322eULL,
    0xbf84470805e69b5fULL, 0x94c3251f06f90cf3ULL, 0x3e003e616a6591e9ULL, 0xb925a6cd0421aff3ULL,
    0x61bdd1307c66e300ULL, 0xbf8d5108e27e0d48ULL, 0x240ab57a8b888b20ULL, 0xfc87614baf287e07ULL,
    0xef02cdd06ffdb432ULL, 0xa1082c0466df6c0aULL, 0x8215e577001332c8ULL, 0xd39bb9c3a48db6cfULL,
    0x2738259634305c14ULL, 0x61cf4f94c97df93dULL, 0x1b6baca2ae4e125bULL, 0x758f450c88572e0bULL,
    0x959f587d507a8359ULL, 0xb063e962e045f54dULL, 0x60e8ed72c0dff5d1ULL, 0x7b64978555326f9fULL,
    0xfd080d236da814baULL, 0x8c90fd9b083f4558ULL, 0x106f72fe81e2c590ULL, 0x7976033a39f7d952ULL,
    0xa4ec0132764ca04bULL, 0x733ea705fae4fa77ULL, 0xb4d8f77bc3e56167ULL, 0x9e21f4f903b33fd9ULL,
    0x9d765e419fb69f6dULL, 0xd30c088ba61ea5efULL, 0x5d94337fbfaf7f5bULL, 0x1a4e4822eb4d7a59ULL,
    0x6ffe73e81b637fb3ULL, 0xddf957bc36d8b9caULL, 0x64d0e29eea8838b3ULL, 0x08dd9bdfd96b9f63ULL,
    0x087e79e5a57d1d13ULL, 0xe328e230e3e2b3fbULL, 0x1c2559e30f0946beULL, 0x720bf5f26f4d2eaaULL,
    0xb0774d261cc609dbULL, 0x443f64ec5a371195ULL, 0x4112cf68649a260eULL, 0xd813f2fab7f5c5caULL,
    0x660d3257380841eeULL, 0x59ac2c7873f910a3ULL, 0xe846963877671a17ULL, 0x93b633abfa3469f8ULL,
    0xc0c0f5a60ef4cdcfULL, 0xcaf21ecd4377b28cULL, 0x57277707199b8175ULL, 0x506c11b9d90e8b1dULL,
    0xd83cc2687a19255fULL, 0x4a29c6465a314cd1ULL, 0xed2df21216235097ULL, 0xb5635c95ff7296e2ULL,
    0x22af003ab672e811ULL, 0x52e762596bf68235ULL, 0x9aeba33ac6ecc6b0ULL, 0x944f6de09134dfb6ULL,
    0x6c47bec883a7de39ULL, 0x6ad047c430a12104ULL, 0xa5b1cfdba0ab4067ULL, 0x7c45d833aff07862ULL,
    0x5092ef950a16da0bULL, 0x9338e69c052b8e7bULL, 0x455a4b4cfe30e3f5ULL, 0x6b02e63195ad0cf8ULL,
    0x6b17b224bad6bf27ULL, 0xd1e0ccd25bb9c169ULL, 0xde0c89a556b9ae70ULL, 0x50065e535a213cf6ULL,
    0x9c1169fa2777b874ULL, 0x78edefd694af1eedULL, 0x6dc93d9526a50e68ULL, 0xee97f453f06791edULL,
    0x32ab0edb696703d3ULL, 0x3a6853c7e70757a7ULL, 0x31865ced6120f37dULL, 0x67fef95d92607890ULL,
    0x1f2b1d1f15f6dc9cULL, 0xb69e38a8965c6b65ULL, 0xaa9119ff184cccf4ULL, 0xf43c732873f24c13ULL,
    0xfb4a3d794a9a80d2ULL, 0x3550c2321fd6109cULL, 0x371f77e76bb8417eULL, 0x6bfa9aae5ec05779ULL,
    0xcd04f3ff001a4778ULL, 0xe3273522064480caULL, 0x9f91508bffcfc14aULL, 0x049a7f41061a9e60ULL,
    0xfcb6be43a9f2fe9bULL, 0x08de8a1c7797da9bULL, 0x8f9887e6078735a1ULL, 0xb5b4071dbfc73a66ULL,
    0x230e343dfba08d33ULL, 0x43ed7f5a0fae657dULL, 0x3a88a0fbbcb05c63ULL, 0x21874b8b4d2dbc4fULL,
    0x1bdea12e35f6a8c9ULL, 0x53c065c6c8e63528ULL, 0xe34a1d250e7a8d6bULL, 0xd6b04d3b7651dd7eULL,
    0x5e90277e7cb39e2dULL, 0x2c046f22062dc67dULL, 0xb10bb459132d0a26ULL, 0x3fa9ddfb67e2f199ULL,
    0x0e09b88e1914f7afULL, 0x10e8b35af3eeab37ULL, 0x9eedeca8e272b933ULL, 0xd4c718bc4ae8ae5fULL,
    0x81536d601170fc20ULL, 0x91b534f885818a06ULL, 0xec8177f83f900978ULL, 0x190e714fada5156eULL,
    0xb592bf39b0364963ULL, 0x89c350c893ae7dc1ULL, 0xac042e70f8b383f2ULL, 0xb49b52e587a1ee60ULL,
    0xfb152fe3ff26da89ULL, 0x3e666e6f69ae2c15ULL, 0x3b544ebe544c19f9ULL, 0xe805a1e290cf2456ULL,
    0x24b33c9d7ed25117ULL, 0xe74733427b72f0c1ULL, 0x0a804d18b7097475ULL, 0x57e3306d881edb4fULL,
    0x4ae7d6a36eb5dbcbULL, 0x2d8d5432157064c8ULL, 0xd1e649de1e7f268bULL, 0x8a328a1cedfe552cULL,
    0x07a3aec79624c7daULL, 0x84547ddc3e203c94ULL, 0x990a98fd5071d263ULL, 0x1a4ff12616eefc89ULL,
    0xf6f7fd1431714200ULL, 0x30c05b1ba332f41cULL, 0x8d2636b81555a786ULL, 0x46c9feb55d120902ULL,
    0xccec0a73b49c9921ULL, 0x4e9d2827355fc492ULL, 0x19ebb029435dcb0fULL, 0x4659d2b743848a2cULL,
    0x963ef2c96b33be31ULL, 0x74f85198b05a2e7dULL, 0x5a0f544dd2b1fb18ULL, 0x03727073c2e134b1ULL,
    0xc7f6aa2de59aea61ULL, 0x352787baa0d7c22fULL, 0x9853eab63b5e0b35ULL, 0xabbdcdd7ed5c0860ULL,
    0xcf05daf5ac8d77b0ULL, 0x49cad48cebf4a71eULL, 0x7a4c10ec2158c4a6ULL, 0xd9e92aa246bf719eULL,
    0x13ae978d09fe5557ULL, 0x730499af921549ffULL, 0x4e4b705b92903ba4ULL, 0xff577222c14f0a3aULL,
    0x55b6344cf97aafaeULL, 0xb862225b055b6960ULL, 0xcac09afbddd2cdb4ULL, 0xdaf8e9829fe96b5fULL,
    0xb5fdfc5d3132c498ULL, 0x310cb380db6f7503ULL, 0xe87fbb46217a360eULL, 0x2102ae466ebb1148ULL,
    0xf8549e1a3aa5e00dULL, 0x07a69afdcc42261aULL, 0xc4c118bfe78feaaeULL, 0xf9f4892ed96bd438ULL,
    0x1af3dbe25d8f45daULL, 0xf5b4b0b0d2deeeb4ULL, 0x962aceefa82e1c84ULL, 0x046e3ecaaf453ce9ULL,
    0xf05d129681949a4cULL, 0x964781ce734b3c84ULL, 0x9c2ed44081ce5fbdULL, 0x522e23f3925e319eULL,
    0x177e00f9fc32f791ULL, 0x2bc60a63a6f3b3f2ULL, 0x222bbfae61725606ULL, 0x486289ddcc3d6780ULL,
    0x7dc7785b8efdfc80ULL, 0x8af38731c02ba980ULL, 0x1fab64ea29a2ddf7ULL, 0xe4d9429322cd065aULL,
    0x9da058c67844f20cULL, 0x24c0e332b70019b0ULL, 0x233003b5a6cfe6adULL, 0xd586bd01c5c217f6ULL,
    0x5e5637885f29bc2bULL, 0x7eba726d8c94094bULL, 0x0a56a5f0bfe39272ULL, 0xd79476a84ee20d06ULL,
    0x9e4c1269baa4bf37ULL, 0x17efee45b0dee640ULL, 0x1d95b0a5fcf90bc6ULL, 0x93cbe0b699c2585dULL,
    0x65fa4f227a2b6d79ULL, 0xd5f9e858292504d5ULL, 0xc2b5a03f71471a6fULL, 0x59300222b4561e00ULL,
    0xce2f8642ca0712dcULL, 0x7ca9723fbb2e8988ULL, 0x2785338347f2ba08ULL, 0xc61bb3a141e50e8cULL,
    0x150f361dab9dec26ULL, 0x9f6a419d382595f4ULL, 0x64a53dc924fe7ac9ULL, 0x142de49fff7a7c3dULL,
    0x0c335248857fa9e7ULL, 0x0a9c32d5eae45305ULL, 0xe6c42178c4bbb92eULL, 0x71f1ce2490d20b07ULL,
    0xf1bcc3d275afe51aULL, 0xe728e8c83c334074ULL, 0x96fbf83a12884624ULL, 0x81a1549fd6573da5ULL,
    0x5fa7867caf35e149ULL, 0x56986e2ef3ed091bULL, 0x917f1dd5f8886c61ULL, 0xd20d8c88c8ffe65fULL,
    0x31d71dce64b2c310ULL, 0xf165b587df898190ULL, 0xa57e6339dd2cf3a0ULL, 0x1ef6e6dbb1961ec9ULL,
    0x70cc73d90bc26e24ULL, 0xe21a6b35df0c3ad7ULL, 0x003a93d8b2806962ULL, 0x1c99ded33cb890a1ULL,
    0xcf3145de0add4289ULL, 0xd0e4427a5514fb72ULL, 0x77c621cc9fb3a483ULL, 0x67a34dac4356550bULL,
    0xf8d626aaaf278509ULL,
};
// code -> piece, nth occurrence, forward, right (piece 0 = no move)
static const MoveCode MOVETABLE[256] = {
    {'P', 5, 1, 1}, {'N', 2, -1, -2}, {0, 0, 0, 0}, {'Q', 2, 0, 2},  // 0x00
    {'P', 2, 1, 0}, {'Q', 1, 1, 0}, {'P', 4, 1, -1}, {0, 0, 0, 0},  // 0x04
    {'Q', 2, 0, 4}, {'B', 2, 6, 6}, {'K', 1, -1, 0}, {0, 0, 0, 0},  // 0x08
    {'P', 1, 1, -1}, {'B', 1, 3, 3}, {'R', 2, 0, 3}, {'N', 1, -1, -2},  // 0x0c
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'B', 1, 7, 7}, {'K', 1, 1, 0},  // 0x10
    {'P', 8, 1, 1}, {'B', 1, 5, 5}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x14
    {'P', 7, 1, 0}, {0, 0, 0, 0}, {'Q', 2, 6, 0}, {'B', 1, 1, -1},  // 0x18
    {0, 0, 0, 0}, {'B', 2, 7, 7}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x1c
    {0, 0, 0, 0}, {'R', 2, 0, 7}, {'B', 2, 2, -2}, {'Q', 2, 6, 6},  // 0x20
    {'P', 8, 1, -1}, {0, 0, 0, 0}, {'B', 1, 7, -7}, {'P', 3, 1, -1},  // 0x24
    {'Q', 1, 5, 5}, {'Q', 1, 0, 6}, {'N', 2, -2, 1}, {0, 0, 0, 0},  // 0x28
    {0, 0, 0, 0}, {'P', 6, 1, 1}, {'B', 1, 1, 1}, {'Q', 1, 0, 1},  // 0x2c
    {'N', 2, -2, -1}, {'Q', 1, 0, 3}, {'B', 2, 5, 5}, {0, 0, 0, 0},  // 0x30
    {'N', 1, 2, 1}, {0, 0, 0, 0}, {'N', 1, 1, 2}, {'Q', 1, 4, 0},  // 0x34
    {'Q', 2, 4, -4}, {'Q', 1, 0, 5}, {'B', 1, 6, 6}, {'Q', 2, 5, -5},  // 0x38
    {'B', 1, 5, -5}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x3c
    {0, 0, 0, 0}, {'Q', 2, 5, 5}, {'Q', 1, 7, -7}, {0, 0, 0, 0},  // 0x40
    {'K', 1, -1, 1}, {'Q', 1, 3, 3}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x44
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'P', 8, 2, 0}, {'Q', 1, 5, -5},  // 0x48
    {'N', 2, 2, 1}, {'Q', 2, 1, 0}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x4c
    {'R', 1, 6, 0}, {0, 0, 0, 0}, {'R', 1, 0, 6}, {0, 0, 0, 0},  // 0x50
    {'B', 2, 1, -1}, {'P', 3, 1, 0}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x54
    {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x58
    {'P', 7, 1, 1}, {0, 0, 0, 0}, {0, 0, 0, 0}, {'P', 5, 2, 0},  // 0x5c
    {0, 0, 0, 0}, {'Q', 1, 6, 6}, {'P', 2, 2, 0}, {'Q', 2, 7, -7},  // 0x60
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'B', 1, 3, -3}, {'K', 1, 1, 1},  // 0x64
    {0, 0, 0, 0}, {'R', 2, 7, 0}, {'B', 1, 4, 4}, {'K', 1, 0, 2},  // 0x68
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'R', 1, 0, 5}, {'Q', 2, 7, 7},  // 0x6c
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'B', 2, 7, -7}, {0, 0, 0, 0},  // 0x70
    {'Q', 1, 0, 2}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0x74
    {0, 0, 0, 0}, {'B', 2, 6, -6}, {'R', 1, 3, 0}, {'R', 2, 6, 0},  // 0x78
    {'P', 3, 1, 1}, {'R', 2, 1, 0}, {'Q', 1, 3, -3}, {'R', 1, 0, 1},  // 0x7c
    {'Q', 1, 6, -6}, {'R', 1, 1, 0}, {'P', 6, 1, -1}, {0, 0, 0, 0},  // 0x80
    {0, 0, 0, 0}, {'N', 1, 2, -1}, {'R', 1, 0, 7}, {'R', 1, 5, 0},  // 0x84
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'N', 1, -2, 1}, {'P', 1, 1, 1},  // 0x88
    {'K', 1, -1, -1}, {0, 0, 0, 0}, {'Q', 2, 2, -2}, {'Q', 1, 0, 7},  // 0x8c
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'Q', 2, 1, 1}, {0, 0, 0, 0},  // 0x90
    {'Q', 1, 3, 0}, {0, 0, 0, 0}, {'P', 2, 1, 1}, {'K', 1, 0, -1},  // 0x94
    {'R', 1, 0, 3}, {'R', 1, 4, 0}, {'Q', 1, 6, 0}, {'P', 3, 2, 0},  // 0x98
    {0, 0, 0, 0}, {'Q', 1, 2, 0}, {0, 0, 0, 0}, {'B', 2, 4, -4},  // 0x9c
    {'Q', 2, 3, 0}, {0, 0, 0, 0}, {'Q', 1, 2, 2}, {'P', 8, 1, 0},  // 0xa0
    {0, 0, 0, 0}, {'R', 2, 5, 0}, {0, 0, 0, 0}, {0, 0, 0, 0},  // 0xa4
    {0, 0, 0, 0}, {'R', 2, 0, 2}, {0, 0, 0, 0}, {'Q', 2, 6, -6},  // 0xa8
    {0, 0, 0, 0}, {'R', 2, 0, 4}, {'Q', 2, 3, 3}, {0, 0, 0, 0},  // 0xac
    {'Q', 2, 4, 0}, {'P', 6, 2, 0}, {'B', 1, 6, -6}, {0, 0, 0, 0},  // 0xb0
    {0, 0, 0, 0}, {'R', 2, 0, 5}, {0, 0, 0, 0}, {'Q', 1, 5, 0},  // 0xb4
    {0, 0, 0, 0}, {'B', 2, 3, 3}, {0, 0, 0, 0}, {'P', 5, 1, 0},  // 0xb8
    {'Q', 2, 0, 5}, {'Q', 2, 2, 0}, {'K', 1, 0, 1}, {0, 0, 0, 0},  // 0xbc
    {0, 0, 0, 0}, {'B', 1, 2, 2}, {'B', 2, 2, 2}, {'B', 1, 2, -2},  // 0xc0
    {'R', 2, 0, 1}, {'R', 2, 4, 0}, {'Q', 2, 5, 0}, {'P', 7, 1, -1},  // 0xc4
    {'P', 7, 2, 0}, {'Q', 2, 7, 0}, {'B', 2, 3, -3}, {'P', 6, 1, 0},  // 0xc8
    {'B', 2, 5, -5}, {'R', 1, 0, 2}, {0, 0, 0, 0}, {'P', 4, 1, 0},  // 0xcc
    {0, 0, 0, 0}, {'P', 2, 1, -1}, {'N', 2, 1, 2}, {'N', 2, 1, -2},  // 0xd0
    {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {'Q', 1, 1, -1},  // 0xd4
    {'R', 2, 0, 6}, {'Q', 1, 2, -2}, {'N', 1, -2, -1}, {'P', 1, 2, 0},  // 0xd8
    {0, 0, 0, 0}, {0, 0, 0, 0}, {'P', 5, 1, -1}, {'K', 1, 1, -1},  // 0xdc
    {'N', 2, -1, 2}, {'R', 1, 7, 0}, {0, 0, 0, 0}, {'R', 2, 3, 0},  // 0xe0
    {0, 0, 0, 0}, {'Q', 1, 0, 4}, {'P', 4, 2, 0}, {'Q', 1, 4, 4},  // 0xe4
    {'R', 1, 2, 0}, {'N', 1, -1, 2}, {0, 0, 0, 0}, {'P', 4, 1, 1},  // 0xe8
    {'P', 1, 1, 0}, {'Q', 1, 7, 7}, {'Q', 2, 1, -1}, {'R', 1, 0, 4},  // 0xec
    {'Q', 2, 0, 7}, {'Q', 1, 1, 1}, {0, 0, 0, 0}, {'N', 2, 2, -1},  // 0xf0
    {'R', 2, 2, 0}, {'B', 2, 1, 1}, {'K', 1, 0, -2}, {'N', 1, 1, -2},  // 0xf4
    {'Q', 2, 0, 1}, {'Q', 2, 0, 6}, {'Q', 2, 0, 3}, {'Q', 2, 2, 2},  // 0xf8
    {0, 0, 0, 0}, {'Q', 1, 7, 0}, {'Q', 2, 3, -3}, {0, 0, 0, 0},  // 0xfc
};
static const uint32_t TBL2[64] = {
    0x3100d2bf, 0x3118e3de, 0x34ab1372, 0x2807a847, 0x1633f566, 0x2143b359, 0x26d56488, 0x3b9e6f59,
    0x37755656, 0x3089ca7b, 0x18e92d85, 0x0cd0e9d8, 0x1a9e3b54, 0x3eaa902f, 0x0d9bfaae, 0x2f32b45b,
    0x31ed6102, 0x3d3c8398, 0x146660e3, 0x0f8d4b76, 0x02c77a5f, 0x146c8799, 0x1c47f51f, 0x249f8f36,
    0x24772043, 0x1fbc1e4d, 0x1e86b3fa, 0x37df36a6, 0x16ed30e4, 0x02c3148e, 0x216e5929, 0x0636b34e,
    0x317f9f56, 0x15f09d70, 0x131026fb, 0x38c784b1, 0x29ac3305, 0x2b485dc5, 0x3c049ddc, 0x35a9fbcd,
    0x31d5373b, 0x2b246799, 0x0a2923d3, 0x08a96e9d, 0x30031a9f, 0x08f525b5, 0x33611c06, 0x2409db98,
    0x0ca4feb2, 0x1000b71e, 0x30566e32, 0x39447d31, 0x194e3752, 0x08233a95, 0x0f38fe36, 0x29c7cd57,
    0x0f7b3a39, 0x328e8a16, 0x1e7d1388, 0x0fba78f5, 0x274c7e7c, 0x1e8be65c, 0x2fa0b0bb, 0x1eb6c371,
};

static const int PAGE = 4096;
static const int SLOTS = 128;
static const uint32_t NO_CHILD = 0xFFFFFFFFu;

// ------------------------------------------------------------ files

// Paths are UTF-8, as Tcl passes them.
std::filesystem::path u8(const std::string& s) {
    auto p = reinterpret_cast<const char8_t*>(s.data());
    return std::filesystem::path(p, p + s.size());
}

FILE* fopen_utf8(const std::string& path, const char* mode) {
#ifdef _WIN32
    std::wstring wmode(mode, mode + std::strlen(mode));
    return _wfopen(u8(path).c_str(), wmode.c_str());
#else
    return std::fopen(path.c_str(), mode);
#endif
}

// Read-only memory map of the .ctg file.
struct Mapped {
    const uint8_t* p = nullptr;
    size_t n = 0;
#ifdef _WIN32
    HANDLE f = INVALID_HANDLE_VALUE, m = nullptr;
    void open(const std::string& path) {
        f = CreateFileW(u8(path).c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL, nullptr);
        if (f == INVALID_HANDLE_VALUE) throw std::runtime_error("cannot open " + path);
        LARGE_INTEGER sz;
        GetFileSizeEx(f, &sz);
        n = (size_t)sz.QuadPart;
        m = CreateFileMappingW(f, nullptr, PAGE_READONLY, 0, 0, nullptr);
        if (!m) throw std::runtime_error("cannot map " + path);
        p = (const uint8_t*)MapViewOfFile(m, FILE_MAP_READ, 0, 0, 0);
        if (!p) throw std::runtime_error("cannot map " + path);
    }
    ~Mapped() {
        if (p) UnmapViewOfFile(p);
        if (m) CloseHandle(m);
        if (f != INVALID_HANDLE_VALUE) CloseHandle(f);
    }
#else
    int fd = -1;
    void open(const std::string& path) {
        fd = ::open(path.c_str(), O_RDONLY);
        if (fd < 0) throw std::runtime_error("cannot open " + path);
        struct stat st;
        fstat(fd, &st);
        n = (size_t)st.st_size;
        void* q = mmap(nullptr, n, PROT_READ, MAP_SHARED, fd, 0);
        if (q == MAP_FAILED) throw std::runtime_error("cannot map " + path);
        p = (const uint8_t*)q;
    }
    ~Mapped() {
        if (p) munmap((void*)p, n);
        if (fd >= 0) close(fd);
    }
#endif
};

static bool read_file(const std::string& path, std::vector<uint8_t>& out) {
    FILE* f = fopen_utf8(path, "rb");
    if (!f) return false;
    out.clear();
    uint8_t buf[65536];
    size_t k;
    while ((k = std::fread(buf, 1, sizeof buf, f)) > 0) out.insert(out.end(), buf, buf + k);
    std::fclose(f);
    return true;
}

static uint32_t be(const uint8_t* p, int n) {
    uint32_t v = 0;
    for (int i = 0; i < n; i++) v = (v << 8) | p[i];
    return v;
}

// ------------------------------------------------------------ chess (python-chess semantics)

// Squares a1=0 .. h8=63. Pieces are python-chess symbols, ' ' empty.
// Castling rights are a bitmask of the corner squares, as in python-chess.
struct Board {
    char sq[64];
    bool black;   // side to move
    uint64_t cr;  // castling rights (corner squares)
    int ep;       // en passant square or -1
};

static const uint64_t A1 = 1ULL << 0, H1 = 1ULL << 7, A8 = 1ULL << 56, H8 = 1ULL << 63;

static bool is_white(char c) { return c >= 'A' && c <= 'Z'; }
static char swapcase(char c) { return is_white(c) ? (char)std::tolower(c) : (char)std::toupper(c); }
static bool own(char c, bool black) { return c != ' ' && is_white(c) != black; }

static Board start_board() {
    Board b;
    const char* r8 = "rnbqkbnr";
    for (int f = 0; f < 8; f++) {
        b.sq[f] = (char)std::toupper(r8[f]);
        b.sq[8 + f] = 'P';
        b.sq[48 + f] = 'p';
        b.sq[56 + f] = r8[f];
        for (int r = 2; r < 6; r++) b.sq[r * 8 + f] = ' ';
    }
    b.black = false;
    b.cr = A1 | H1 | A8 | H8;
    b.ep = -1;
    return b;
}

// Board.clean_castling_rights() for standard chess.
static uint64_t clean_cr(const Board& b) {
    uint64_t w = 0, k = 0;
    if ((b.cr & A1) && b.sq[0] == 'R') w |= A1;
    if ((b.cr & H1) && b.sq[7] == 'R') w |= H1;
    if ((b.cr & A8) && b.sq[56] == 'r') k |= A8;
    if ((b.cr & H8) && b.sq[63] == 'r') k |= H8;
    if (b.sq[4] != 'K') w = 0;
    if (b.sq[60] != 'k') k = 0;
    return w | k;
}

static char piece_at(const Board& b, int f, int r) {
    return (f >= 0 && f < 8 && r >= 0 && r < 8) ? b.sq[r * 8 + f] : 0;
}

static const int KN[8][2] = {{1, 2}, {2, 1}, {-1, 2}, {-2, 1}, {1, -2}, {2, -1}, {-1, -2}, {-2, -1}};
static const int DIRS[8][2] = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}};

// Is square s attacked by the given colour?
static bool attacked(const Board& b, int s, bool by_black) {
    int f = s & 7, r = s >> 3;
    auto is = [&](char c, char upper) { return c && c != ' ' && is_white(c) != by_black && std::toupper(c) == upper; };
    int pr = by_black ? r + 1 : r - 1;
    if (is(piece_at(b, f - 1, pr), 'P') || is(piece_at(b, f + 1, pr), 'P')) return true;
    for (auto& d : KN)
        if (is(piece_at(b, f + d[0], r + d[1]), 'N')) return true;
    for (auto& d : DIRS)
        if (is(piece_at(b, f + d[0], r + d[1]), 'K')) return true;
    for (int i = 0; i < 8; i++) {
        char slider = i < 4 ? 'R' : 'B';
        for (int ff = f + DIRS[i][0], rr = r + DIRS[i][1]; ff >= 0 && ff < 8 && rr >= 0 && rr < 8;
             ff += DIRS[i][0], rr += DIRS[i][1]) {
            char c = b.sq[rr * 8 + ff];
            if (c == ' ') continue;
            if (is(c, slider) || is(c, 'Q')) return true;
            break;
        }
    }
    return false;
}

struct Move { int from, to; bool promo; };

// Is m a castling move that python-chess would generate (king two files from e1/e8)?
static bool castling_ok(const Board& b, const Move& m) {
    int base = b.black ? 56 : 0;
    char k = b.black ? 'k' : 'K';
    if (m.from != base + 4 || b.sq[m.from] != k || m.promo) return false;
    uint64_t c = clean_cr(b);
    bool opp = !b.black;
    auto empty = [&](int f) { return b.sq[base + f] == ' '; };
    auto safe = [&](int f) { return !attacked(b, base + f, opp); };
    if (m.to == base + 6 && (c & (1ULL << (base + 7))))
        return empty(5) && empty(6) && safe(4) && safe(5) && safe(6);
    if (m.to == base + 2 && (c & (1ULL << base)))
        return empty(1) && empty(2) && empty(3) && safe(4) && safe(3) && safe(2);
    return false;
}

// Board.is_pseudo_legal() for the moves decode_move can produce (no drops, promotion only to queen).
static bool pseudo_legal(const Board& b, const Move& m, bool& castle) {
    castle = false;
    char pc = b.sq[m.from];
    if (!own(pc, b.black) || m.from == m.to) return false;
    char up = (char)std::toupper(pc);
    int ff = m.from & 7, fr = m.from >> 3, tf = m.to & 7, tr = m.to >> 3;
    int df = tf - ff, dr = tr - fr;
    char tgt = b.sq[m.to];
    if (m.promo && up != 'P') return false;
    if (up == 'K' && castling_ok(b, m)) return castle = true;
    if (own(tgt, b.black)) return false;
    if (up == 'P') {
        int dir = b.black ? -1 : 1;
        if (m.promo != (tr == (b.black ? 0 : 7))) return false;
        if (df == 0 && dr == dir) return tgt == ' ';
        if (df == 0 && dr == 2 * dir && fr == (b.black ? 6 : 1))
            return tgt == ' ' && b.sq[m.from + 8 * dir] == ' ';
        if ((df == 1 || df == -1) && dr == dir) return tgt != ' ' || m.to == b.ep;
        return false;
    }
    if (up == 'N') return (std::abs(df) == 1 && std::abs(dr) == 2) || (std::abs(df) == 2 && std::abs(dr) == 1);
    if (up == 'K') return std::abs(df) <= 1 && std::abs(dr) <= 1;
    bool straight = df == 0 || dr == 0, diag = std::abs(df) == std::abs(dr);
    if (!((up == 'R' && straight) || (up == 'B' && diag) || (up == 'Q' && (straight || diag)))) return false;
    int sf = (df > 0) - (df < 0), sr = (dr > 0) - (dr < 0);
    for (int f = ff + sf, r = fr + sr; f != tf || r != tr; f += sf, r += sr)
        if (b.sq[r * 8 + f] != ' ') return false;
    return true;
}

// Board.push(): castling rights, en passant, promotion, castling.
static Board make_move(const Board& b, const Move& m, bool castle) {
    Board n = b;
    n.ep = -1;
    char pc = b.sq[m.from];
    char up = (char)std::toupper(pc);
    uint64_t rank_bits = b.black ? (A8 | H8) : (A1 | H1);
    n.cr = clean_cr(b) & ~(1ULL << m.to) & ~(1ULL << m.from);
    if (up == 'K') n.cr &= ~rank_bits;
    n.sq[m.from] = ' ';
    if (up == 'P') {
        int diff = m.to - m.from;
        if (diff == 16 && (m.from >> 3) == 1) n.ep = m.from + 8;
        else if (diff == -16 && (m.from >> 3) == 6) n.ep = m.from - 8;
        else if (m.to == b.ep && (std::abs(diff) == 7 || std::abs(diff) == 9) && b.sq[m.to] == ' ')
            n.sq[b.ep + (b.black ? 8 : -8)] = ' ';
    }
    if (castle) {
        int base = b.black ? 56 : 0;
        bool a_side = (m.to & 7) < (m.from & 7);
        n.sq[base + (a_side ? 0 : 7)] = ' ';
        n.sq[base + (a_side ? 2 : 6)] = pc;
        n.sq[base + (a_side ? 3 : 5)] = b.black ? 'r' : 'R';
    } else {
        n.sq[m.to] = m.promo ? (b.black ? 'q' : 'Q') : pc;
    }
    n.black = !b.black;
    return n;
}

static bool legal(const Board& b, const Move& m, bool& castle, Board& after) {
    if (!pseudo_legal(b, m, castle)) return false;
    after = make_move(b, m, castle);
    char k = b.black ? 'k' : 'K';
    for (int s = 0; s < 64; s++)
        if (after.sq[s] == k) return !attacked(after, s, !b.black);
    return true;  // no king: python-chess treats it as not in check
}

// chess.polyglot.zobrist_hash()
static uint64_t zobrist(const Board& b) {
    static const char* TYPES = "PNBRQK";
    uint64_t h = 0;
    for (int s = 0; s < 64; s++) {
        char c = b.sq[s];
        if (c == ' ') continue;
        int t = (int)(std::strchr(TYPES, std::toupper(c)) - TYPES);
        h ^= ZOBRIST[64 * (t * 2 + (is_white(c) ? 1 : 0)) + s];
    }
    uint64_t c = clean_cr(b);
    if (c & H1) h ^= ZOBRIST[768];
    if (c & A1) h ^= ZOBRIST[769];
    if (c & H8) h ^= ZOBRIST[770];
    if (c & A8) h ^= ZOBRIST[771];
    if (b.ep > 0) {  // python-chess tests "if board.ep_square:"
        int f = b.ep & 7, r = (b.ep >> 3) + (b.black ? 1 : -1);
        char p = b.black ? 'p' : 'P';
        if (piece_at(b, f - 1, r) == p || piece_at(b, f + 1, r) == p) h ^= ZOBRIST[772 + f];
    }
    if (!b.black) h ^= ZOBRIST[780];
    return h;
}

static uint64_t map_bits(uint64_t bits, int x) {
    uint64_t o = 0;
    for (int s = 0; s < 64; s++)
        if (bits >> s & 1) o |= 1ULL << (s ^ x);
    return o;
}

// Board.mirror(): flip ranks, swap colours and side to move.
static Board mirror(const Board& b) {
    Board n;
    for (int s = 0; s < 64; s++) n.sq[s ^ 56] = b.sq[s] == ' ' ? ' ' : swapcase(b.sq[s]);
    n.black = !b.black;
    n.cr = map_bits(b.cr, 56);
    n.ep = b.ep < 0 ? -1 : b.ep ^ 56;
    return n;
}

// Board.transform(chess.flip_horizontal)
static Board flip_h(const Board& b) {
    Board n;
    for (int s = 0; s < 64; s++) n.sq[s ^ 7] = b.sq[s];
    n.black = b.black;
    n.cr = map_bits(b.cr, 7);
    n.ep = b.ep < 0 ? -1 : b.ep ^ 7;
    return n;
}

// Polyglot 16-bit move (castling as king takes rook).
static uint16_t pg_move(const Move& m, bool castle) {
    int to = m.to;
    if (castle) to = (m.from & ~7) | ((m.to & 7) > (m.from & 7) ? 7 : 0);
    return (uint16_t)(((m.promo ? 4 : 0) << 12) | (m.from << 6) | to);
}

// ------------------------------------------------------------ CTG codec (ctglib.py)

// "byteboard": index row*8+file, row 0 = rank 8.
struct Norm {
    char bb[64];
    bool inv = false, flip = false;
    uint8_t pos[32];
    int plen = 0;
};

static const char* huff(char c) {
    switch (c) {
        case ' ': return "0";
        case 'P': return "110"; case 'p': return "111";
        case 'R': return "10110"; case 'r': return "10111";
        case 'B': return "10100"; case 'b': return "10101";
        case 'N': return "10010"; case 'n': return "10011";
        case 'Q': return "100010"; case 'q': return "100011";
        case 'K': return "100000"; case 'k': return "100001";
    }
    throw std::runtime_error("bad piece");
}

static int encode_position(const char* bb, const int* castle, int ep_file, uint8_t* out) {
    std::string bits;
    for (int x = 0; x < 8; x++)
        for (int y = 0; y < 8; y++) bits += huff(bb[(7 - y) * 8 + x]);
    int bits_left = 8 - (int)(bits.size() % 8);
    bool ep_any = ep_file >= 0;
    int right = ep_any ? 3 : 8;
    if (castle) {
        right += 4;
        if (right > 8) right %= 8;
    }
    int nb = bits_left > right ? bits_left - right : bits_left < right ? bits_left + 8 - right : 0;
    if (bits_left == 8 && !castle && !ep_any) nb = 8;
    bits.append(nb, '0');
    if (ep_any)
        for (int i = 2; i >= 0; i--) bits += (ep_file >> i & 1) ? '1' : '0';
    if (castle)
        for (int i = 0; i < 4; i++) bits += castle[i] ? '1' : '0';
    if (bits.size() % 8) bits.append(8 - bits.size() % 8, '0');
    int len = (int)bits.size() / 8;
    if (len + 1 > 31) throw std::runtime_error("position too long");
    for (int i = 0; i < len; i++) {
        uint8_t v = 0;
        for (int j = 0; j < 8; j++) v = (uint8_t)(v << 1 | (bits[i * 8 + j] == '1'));
        out[1 + i] = v;
    }
    out[0] = (uint8_t)((len + 1) | (castle ? 0x40 : 0) | (ep_any ? 0x20 : 0));
    return len + 1;
}

// decode_position(): returns false on a bad Huffman code.
static bool decode_position(const uint8_t* pos, int plen, char* bb, int* castle, bool& has_castle, int& ep) {
    int nbits = (plen - 1) * 8;
    auto bit = [&](int i) { return pos[1 + i / 8] >> (7 - i % 8) & 1; };
    int i = 0;
    bool eof = false;
    auto rd = [&]() { if (i >= nbits) { eof = true; return 0; } return bit(i++); };
    for (int x = 0; x < 8; x++)
        for (int y = 0; y < 8; y++) {
            // Huffman tree of huff(): 0 empty, 11c pawn, 101Rc / 100 1c / 100 01c / 100 00c
            char c;
            if (!rd()) c = ' ';
            else if (rd()) c = 'P';
            else if (rd()) c = rd() ? 'R' : 'B';
            else if (rd()) c = 'N';
            else c = rd() ? 'Q' : 'K';
            if (c != ' ' && rd()) c = (char)std::tolower(c);
            if (eof) return false;
            bb[(7 - y) * 8 + x] = c;
        }
    int end = nbits;
    has_castle = pos[0] & 0x40;
    if (has_castle) {
        for (int k = 0; k < 4; k++) castle[k] = bit(end - 4 + k);
        end -= 4;
    }
    ep = -1;
    if (pos[0] & 0x20) ep = bit(end - 3) << 2 | bit(end - 2) << 1 | bit(end - 1);
    return true;
}

static uint32_t gen_hash(const uint8_t* pos, int plen) {
    uint32_t h = 0, tmp = 0;
    for (int i = 0; i < plen; i++) {
        uint32_t ch = pos[i];  // the i8 cast in Python does not change the low byte masks
        tmp = (tmp + ((0x0f - (ch & 0x0f)) << 2) + 1) & 0xFFFF;
        h += TBL2[tmp & 0x3f];
        tmp = (tmp + ((0xf0 - (ch & 0xf0)) >> 2) + 1) & 0xFFFF;
        h += TBL2[tmp & 0x3f];
    }
    return h;
}

static void mirror_bb(char* bb) {
    for (int r = 0; r < 8; r++)
        for (int f = 0; f < 4; f++) std::swap(bb[r * 8 + f], bb[r * 8 + 7 - f]);
}

static void invert_bb(char* bb) {
    char out[64];
    for (int r = 0; r < 8; r++)
        for (int f = 0; f < 8; f++) {
            char c = bb[r * 8 + f];
            out[(7 - r) * 8 + f] = c == ' ' ? ' ' : swapcase(c);
        }
    std::memcpy(bb, out, 64);
}

// normalise(board, "mirror")
static Norm normalise(const Board& b) {
    Norm n;
    for (int s = 0; s < 64; s++) n.bb[(7 - (s >> 3)) * 8 + (s & 7)] = b.sq[s];
    n.inv = b.black;
    if (n.inv) invert_bb(n.bb);
    int castle[4];
    bool has_castle = b.cr != 0;
    if (has_castle) {
        uint64_t ok = n.inv ? H1 : H8, oq = n.inv ? A1 : A8, mk = n.inv ? H8 : H1, mq = n.inv ? A8 : A1;
        castle[0] = (b.cr & ok) != 0; castle[1] = (b.cr & oq) != 0;
        castle[2] = (b.cr & mk) != 0; castle[3] = (b.cr & mq) != 0;
    }
    int ep_file = -1;
    if (b.ep >= 0) {
        int f = b.ep & 7;
        if ((f > 0 && n.bb[24 + f - 1] == 'P') || (f < 7 && n.bb[24 + f + 1] == 'P')) ep_file = f;
    }
    if (!has_castle) {
        const char* k = (const char*)std::memchr(n.bb, 'K', 64);
        if (!k) throw std::runtime_error("no king for the side to move");
        if ((k - n.bb) % 8 < 4) {
            n.flip = true;
            mirror_bb(n.bb);
            if (ep_file >= 0) ep_file = 7 - ep_file;
        }
    }
    n.plen = encode_position(n.bb, has_castle ? castle : nullptr, ep_file, n.pos);
    return n;
}

// real_board(pos, flags)
static bool real_board(const uint8_t* pos, int plen, int flags, Board& b) {
    char bb[64];
    int castle[4];
    bool has_castle;
    int ep;
    if (!decode_position(pos, plen, bb, castle, has_castle, ep)) return false;
    if (flags & 2) {
        mirror_bb(bb);
        if (ep >= 0) ep = 7 - ep;
    }
    b.black = flags & 1;
    if (b.black) invert_bb(bb);
    for (int i = 0; i < 64; i++) b.sq[(7 - i / 8) * 8 + i % 8] = bb[i];
    b.cr = 0;
    if (has_castle) {
        if (b.black)
            b.cr = (castle[0] ? H1 : 0) | (castle[1] ? A1 : 0) | (castle[2] ? H8 : 0) | (castle[3] ? A8 : 0);
        else
            b.cr = (castle[0] ? H8 : 0) | (castle[1] ? A8 : 0) | (castle[2] ? H1 : 0) | (castle[3] ? A1 : 0);
    }
    b.ep = ep < 0 ? -1 : (b.black ? 2 : 5) * 8 + ep;
    return true;
}

// decode_move(): CTG move code -> move in real coordinates.
static bool decode_move(const Norm& n, int code, Move& m) {
    const MoveCode& mc = MOVETABLE[code];
    if (!mc.piece) return false;
    int occ = mc.num, fr = -1, fc = -1;
    for (int x = 0; x < 8 && fr < 0; x++)
        for (int y = 0; y < 8; y++)
            if (n.bb[(7 - y) * 8 + x] == mc.piece) {
                if (occ == 1) { fr = y; fc = x; break; }
                occ--;
            }
    if (fr < 0) return false;
    int tr = (fr + 8 + mc.fwd) % 8, tc = (fc + 8 + mc.right) % 8;
    if (n.flip) { fc = 7 - fc; tc = 7 - tc; }
    if (n.inv) { fr = 7 - fr; tr = 7 - tr; }
    m.from = fr * 8 + fc;
    m.to = tr * 8 + tc;
    m.promo = mc.piece == 'P' && (tr == 0 || tr == 7);
    return true;
}

// Entry offsets of a page (ctgscan.parse_page). Each entry: pos, moves, 33 stats bytes.
static std::vector<int> parse_page(const uint8_t* page) {
    int n = (int)be(page, 2), p = 4;
    std::vector<int> offs;
    for (int i = 0; i < n; i++) {
        offs.push_back(p);
        int plen = page[p] & 0x1F;
        if (plen == 0) throw std::runtime_error("zero position length");
        p += plen;
        int mlen = page[p];
        if (mlen < 1 || (mlen - 1) % 2) throw std::runtime_error("bad moves length");
        p += mlen + 33;
        if (p > PAGE) throw std::runtime_error("entry overruns page");
    }
    offs.push_back(p);
    return offs;
}

struct Ctg {
    Mapped ctg;
    std::vector<uint8_t> cto;
    int32_t low = 0, high = 0;
    uint32_t npages = 0;

    const uint8_t* page(uint32_t n) const { return ctg.p + (size_t)PAGE * (n + 1); }

    // find_in_page(): (moves offset, slot) or false.
    bool find_in_page(uint32_t pg, const uint8_t* pos, int plen, int& off, int& slot) const {
        if ((size_t)PAGE * (pg + 2) > ctg.n) return false;
        const uint8_t* page = this->page(pg);
        int n = (int)be(page, 2), p = 4;
        for (slot = 0; slot < n; slot++) {
            int l = page[p] & 0x1F;
            if (p + l + 1 > PAGE) return false;
            if (l == plen && std::memcmp(page + p, pos, plen) == 0) {
                off = p + l;
                return true;
            }
            p += l;
            p += page[p] + 33;
            if (p >= PAGE) return false;
        }
        return false;
    }

    // lookup() through the .cto hash table.
    bool lookup(const uint8_t* pos, int plen, uint32_t& pg, int& off, int& slot) const {
        uint32_t h = gen_hash(pos, plen);
        int64_t mask = 0;
        while (mask != 0x7fffffff) {
            int64_t key = (int64_t)(h & (uint32_t)mask) + mask;
            if (key >= low) {
                int64_t o = key * 4 + 16;
                if (o + 4 <= (int64_t)cto.size()) {
                    int32_t p = (int32_t)be(&cto[(size_t)o], 4);
                    if (p >= 0 && find_in_page((uint32_t)p, pos, plen, off, slot)) {
                        pg = (uint32_t)p;
                        return true;
                    }
                }
            }
            if (key >= high) break;
            mask = 2 * mask + 1;
        }
        return false;
    }
};

// ------------------------------------------------------------ walk (ctgwalk.py)

struct Node {
    uint64_t key;
    uint32_t page;
    uint16_t off;
    uint8_t slot, flags;  // flags bit0 black to move, bit1 mirrored
    uint32_t mfirst;      // first move in Walk::moves
    uint8_t mcount;
};

struct BookMove {
    uint16_t pg;
    uint8_t code, annot;
    int32_t child;
    uint8_t status;  // 0 ok, 1 undecodable, 2 illegal, 3 child not in book
};

struct Cancelled {};

// Progress share of each step, in thousandths: walk, aliases, writing.
const size_t P_WALK = 700, P_ALIAS = 850, P_TOTAL = 1000;

void report(const Ctg2ObrProgress& progress, size_t done) {
    if (progress && !progress(done, P_TOTAL)) throw Cancelled();
}

struct Walk {
    const Ctg& book;
    const Ctg2ObrProgress& progress;
    uint64_t entries;  // CTG entries: the walk reaches at most this many nodes
    std::vector<int32_t> node_of;
    std::vector<Node> nodes;
    std::vector<BookMove> moves;
    uint64_t n_moves = 0, undecodable = 0, illegal = 0, child_missing = 0, aliases = 0, transpositions = 0;
    size_t max_depth = 0;

    Walk(const Ctg& b, const Ctg2ObrProgress& p, uint64_t e)
        : book(b), progress(p), entries(e ? e : 1), node_of((size_t)b.npages * SLOTS, -1) {}

    // visit(): node id or -1; isnew when created now.
    int32_t visit(const Board& b, bool& isnew) {
        isnew = false;
        Norm n = normalise(b);
        uint32_t pg;
        int off, slot;
        if (!book.lookup(n.pos, n.plen, pg, off, slot)) return -1;
        if (slot >= SLOTS) throw std::runtime_error("more than 128 entries in a page");
        size_t idx = (size_t)pg * SLOTS + slot;
        uint64_t key = zobrist(b);
        int32_t nid = node_of[idx];
        if (nid >= 0) {
            if (nodes[nid].key != key) aliases++;
            else transpositions++;
            return nid;
        }
        nid = (int32_t)nodes.size();
        node_of[idx] = nid;
        nodes.push_back({key, pg, (uint16_t)off, (uint8_t)slot, (uint8_t)((n.inv ? 1 : 0) | (n.flip ? 2 : 0)), 0, 0});
        isnew = true;
        return nid;
    }

    std::vector<std::pair<Board, int32_t>> expand(int32_t nid, const Board& b) {
        std::vector<std::pair<Board, int32_t>> children;
        Norm n = normalise(b);
        const uint8_t* page = book.page(nodes[nid].page);
        int off = nodes[nid].off;
        int cnt = (page[off] - 1) / 2;
        nodes[nid].mfirst = (uint32_t)moves.size();
        nodes[nid].mcount = (uint8_t)cnt;
        for (int i = 0; i < cnt; i++) {
            uint8_t code = page[off + 1 + 2 * i], an = page[off + 2 + 2 * i];
            n_moves++;
            Move m;
            if (!decode_move(n, code, m)) {
                undecodable++;
                moves.push_back({0, code, an, -1, 1});
                continue;
            }
            bool castle;
            Board after;
            if (!legal(b, m, castle, after)) {
                illegal++;
                moves.push_back({0, code, an, -1, 2});
                continue;
            }
            uint16_t pm = pg_move(m, castle);
            bool isnew;
            int32_t cid = visit(after, isnew);
            if (cid < 0) {
                child_missing++;
                moves.push_back({pm, code, an, -1, 3});
                continue;
            }
            moves.push_back({pm, code, an, cid, 0});
            if (isnew) children.push_back({after, cid});
        }
        return children;
    }

    void run() {
        Board root = start_board();
        bool isnew;
        int32_t nid = visit(root, isnew);
        if (nid < 0) throw std::runtime_error("initial position not in book");
        struct Frame { std::vector<std::pair<Board, int32_t>> ch; size_t i; };
        std::vector<Frame> frames;
        frames.push_back({expand(nid, root), 0});
        size_t next_report = 4096;
        while (!frames.empty()) {
            Frame& f = frames.back();
            if (f.i == f.ch.size()) {
                frames.pop_back();
                continue;
            }
            std::pair<Board, int32_t> c = f.ch[f.i++];
            frames.push_back({expand(c.second, c.first), 0});
            max_depth = std::max(max_depth, frames.size());
            if (nodes.size() >= next_report) {
                report(progress, (size_t)(P_WALK * std::min<uint64_t>(nodes.size(), entries) / entries));
                next_report += 4096;
            }
        }
    }
};

// ------------------------------------------------------------ output

struct Out {
    FILE* f;
    std::vector<uint8_t> buf;
    explicit Out(const std::string& path) : f(fopen_utf8(path, "wb")) {
        if (!f) throw std::runtime_error("cannot write " + path);
    }
    ~Out() { if (f) std::fclose(f); }  // on error, so the partial file can be deleted
    void put(uint64_t v, int n) {
        for (int i = 0; i < n; i++) buf.push_back((uint8_t)(v >> (8 * i)));
        if (buf.size() >= (1 << 20)) flush();
    }
    void bytes(const std::string& s) {
        buf.insert(buf.end(), s.begin(), s.end());
        flush();
    }
    void flush() {
        if (!buf.empty() && std::fwrite(buf.data(), 1, buf.size(), f) != buf.size())
            throw std::runtime_error("write failed");
        buf.clear();
    }
    void close() {
        flush();
        FILE* g = f;
        f = nullptr;
        if (std::fclose(g) != 0) throw std::runtime_error("write failed");
    }
};

static std::string hex(const uint8_t* p, size_t n) {
    static const char* H = "0123456789abcdef";
    std::string s;
    for (size_t i = 0; i < n; i++) {
        s += H[p[i] >> 4];
        s += H[p[i] & 15];
    }
    return s;
}

// json.dumps string (ensure_ascii). Input bytes are taken as Latin-1.
// shortcut: Python decodes the .ini with the locale code page (cp1252 on Windows);
// bytes 0x80-0x9f differ from Latin-1. Map them if such .ini files turn up.
static std::string jstr(const std::string& s) {
    std::string o = "\"";
    char tmp[8];
    for (unsigned char c : s) {
        if (c == '"') o += "\\\"";
        else if (c == '\\') o += "\\\\";
        else if (c == '\n') o += "\\n";
        else if (c == '\r') o += "\\r";
        else if (c == '\t') o += "\\t";
        else if (c == '\b') o += "\\b";
        else if (c == '\f') o += "\\f";
        else if (c < 0x20 || c > 0x7e) {
            std::snprintf(tmp, sizeof tmp, "\\u%04x", c);
            o += tmp;
        } else o += (char)c;
    }
    return o + "\"";
}

static std::string trim(const std::string& s) {
    size_t a = s.find_first_not_of(" \t\r\n\f\v"), b = s.find_last_not_of(" \t\r\n\f\v");
    return a == std::string::npos ? "" : s.substr(a, b - a + 1);
}

// configparser: {section: {lowercased key: value}} as JSON, DEFAULT merged into each section.
// shortcut: no %-interpolation and no multi-line values; add them if an .ini needs them.
static std::string ini_json(const std::string& path) {
    std::vector<uint8_t> raw;
    if (!read_file(path, raw)) return "{}";
    typedef std::vector<std::pair<std::string, std::string>> Opts;
    std::vector<std::pair<std::string, Opts>> secs;
    Opts defaults;
    Opts* cur = nullptr;
    std::string text(raw.begin(), raw.end()), line;
    size_t i = 0;
    while (i <= text.size()) {
        size_t j = text.find('\n', i);
        if (j == std::string::npos) j = text.size();
        line = trim(text.substr(i, j - i));
        i = j + 1;
        if (line.empty() || line[0] == '#' || line[0] == ';') continue;
        if (line[0] == '[' && line.rfind(']') > 1) {
            std::string name = line.substr(1, line.rfind(']') - 1);
            if (name == "DEFAULT") cur = &defaults;
            else {
                secs.push_back({name, {}});
                cur = &secs.back().second;
            }
            continue;
        }
        size_t k = line.find_first_of("=:");
        if (!cur || k == std::string::npos) continue;
        std::string key = trim(line.substr(0, k));
        for (char& c : key) c = (char)std::tolower((unsigned char)c);
        cur->push_back({key, trim(line.substr(k + 1))});
    }
    std::string o = "{";
    for (size_t s = 0; s < secs.size(); s++) {
        Opts opts = secs[s].second;
        for (auto& d : defaults) {
            bool found = false;
            for (auto& kv : opts)
                if (kv.first == d.first) found = true;
            if (!found) opts.push_back(d);
        }
        o += (s ? "," : "") + jstr(secs[s].first) + ":{";
        for (size_t k = 0; k < opts.size(); k++)
            o += (k ? "," : "") + jstr(opts[k].first) + ":" + jstr(opts[k].second);
        o += "}";
    }
    return o + "}";
}

static std::string basename_of(const std::string& p) {
    size_t k = p.find_last_of("/\\");
    return k == std::string::npos ? p : p.substr(k + 1);
}

}  // namespace

// ------------------------------------------------------------ main (build_obr.py)

bool ctg2obr(const std::string& ctg_path, const std::string& out_path, const Ctg2ObrProgress& progress,
             std::string& result) {
    const std::string tmp_path = out_path + ".part";
    try {
        if (ctg_path.size() < 4) throw std::runtime_error("not a .ctg file: " + ctg_path);
        std::string base = ctg_path.substr(0, ctg_path.size() - 4);
        Ctg book;
        book.ctg.open(ctg_path);
        if (book.ctg.n < 32) throw std::runtime_error("ctg file too short");
        if (!read_file(base + ".cto", book.cto) || book.cto.size() < 16) throw std::runtime_error("cannot read .cto");
        std::vector<uint8_t> ctb;
        if (!read_file(base + ".ctb", ctb) || ctb.size() < 12) throw std::runtime_error("cannot read .ctb");
        book.low = (int32_t)be(&ctb[4], 4);
        book.high = (int32_t)be(&ctb[8], 4);
        book.npages = be(book.ctg.p + 16, 4);
        if ((size_t)PAGE * (book.npages + 1) > book.ctg.n) throw std::runtime_error("ctg file truncated");
        const uint8_t* ctg = book.ctg.p;

        uint64_t entries = 0;
        for (uint32_t pg = 0; pg < book.npages; pg++) entries += be(book.page(pg), 2);
        report(progress, 0);
        Walk w(book, progress, entries);
        w.run();
        size_t n = w.nodes.size();
        if (n >= (1u << 30)) throw std::runtime_error("too many positions");

        // Stats of a node: 33 bytes after its moves.
        auto stats = [&](const Node& nd) {
            const uint8_t* mo = ctg + (size_t)(nd.page + 1) * PAGE + nd.off;
            return mo + mo[0];
        };

        // Derivation rules; entries breaking them are kept verbatim (node id order).
        std::string exceptions;
        size_t n_exc = 0;
        for (size_t i = 0; i < n; i++) {
            const uint8_t* st = stats(w.nodes[i]);
            uint64_t total = be(st, 3), a = be(st + 3, 3), b = be(st + 6, 3), d = be(st + 9, 3);
            uint64_t score10 = be(st + 12, 4);
            if (total != a + b + d || score10 != 5 * (2 * a + d) || st[31] || st[32]) {
                exceptions += (n_exc++ ? "," : "") + std::string("{\"key\":") + std::to_string(w.nodes[i].key) +
                              ",\"stats_hex\":" + jstr(hex(st, 33)) + "}";
            }
        }

        // Positions sorted by key.
        std::vector<uint32_t> perm(n), inv(n);
        for (size_t i = 0; i < n; i++) perm[i] = (uint32_t)i;
        std::sort(perm.begin(), perm.end(), [&](uint32_t x, uint32_t y) {
            return w.nodes[x].key != w.nodes[y].key ? w.nodes[x].key < w.nodes[y].key : x < y;
        });
        for (size_t i = 0; i < n; i++) inv[perm[i]] = (uint32_t)i;

        // Raw CTG codes of undecodable/illegal moves, in output move order.
        std::string unplayable;
        size_t n_unpl = 0;
        for (size_t i = 0; i < n; i++) {
            const Node& nd = w.nodes[perm[i]];
            for (int k = 0; k < nd.mcount; k++) {
                const BookMove& m = w.moves[nd.mfirst + k];
                if (m.status == 1 || m.status == 2)
                    unplayable += (n_unpl++ ? "," : "") + std::string("{\"parent_key\":") + std::to_string(nd.key) +
                                  ",\"ctg_code\":" + std::to_string(m.code) + ",\"annot\":" + std::to_string(m.annot) +
                                  ",\"status\":" + std::to_string(m.status) + "}";
            }
        }

        // Aliases (gen_aliases.py): other real positions answered by the same entry,
        // generated in (page, slot) order, then sorted by key keeping the first.
        struct Alias { uint64_t key; uint32_t val, seq; };
        std::vector<Alias> al;
        uint64_t mismatch = 0;
        {
            uint32_t cur = UINT32_MAX;
            std::vector<int> offs;
            for (size_t idx = 0; idx < w.node_of.size(); idx++) {
                if (idx % 65536 == 0) report(progress, P_WALK + (P_ALIAS - P_WALK) * idx / w.node_of.size());
                int32_t nid = w.node_of[idx];
                if (nid < 0) continue;
                uint32_t pg = (uint32_t)(idx / SLOTS);
                if (pg != cur) {
                    offs = parse_page(book.page(pg));
                    cur = pg;
                }
                const uint8_t* pos = book.page(pg) + offs[idx % SLOTS];
                const Node& nd = w.nodes[nid];
                Board b;
                if (!real_board(pos, pos[0] & 0x1F, nd.flags, b) || zobrist(b) != nd.key) {
                    mismatch++;
                    continue;
                }
                Board h = flip_h(b);
                std::pair<int, Board> variants[3] = {{1, mirror(b)}, {2, h}, {3, mirror(h)}};
                int nv = b.cr ? 1 : 3;
                uint64_t seen[4] = {nd.key};
                int ns = 1;
                for (int v = 0; v < nv; v++) {
                    uint64_t k = zobrist(variants[v].second);
                    if (std::find(seen, seen + ns, k) != seen + ns) continue;  // symmetric position
                    seen[ns++] = k;
                    al.push_back({k, (uint32_t)nid | ((uint32_t)variants[v].first << 30), (uint32_t)al.size()});
                }
            }
        }
        std::sort(al.begin(), al.end(), [](const Alias& x, const Alias& y) {
            return x.key != y.key ? x.key < y.key : x.seq < y.seq;
        });
        // Drop repeated keys and keys of real positions.
        size_t na = 0, clashes = 0, j = 0;
        for (size_t i = 0; i < al.size(); i++) {
            if (i && al[i].key == al[i - 1].key) continue;
            while (j < n && w.nodes[perm[j]].key < al[i].key) j++;  // both sorted by key
            if (j < n && w.nodes[perm[j]].key == al[i].key) {
                clashes++;
                continue;
            }
            uint32_t nid = al[i].val & 0x3FFFFFFF;
            al[na++] = {al[i].key, inv[nid] | (al[i].val & 0xC0000000u), 0};
        }
        al.resize(na);

        // Unreached CTG entries, verbatim.
        std::string unreached;
        size_t n_unr = 0;
        uint64_t total_entries = 0;
        for (uint32_t pg = 0; pg < book.npages; pg++) {
            const uint8_t* page = book.page(pg);
            uint32_t count = be(page, 2);
            total_entries += count;
            uint32_t nvis = 0;
            for (int s = 0; s < SLOTS; s++) nvis += w.node_of[(size_t)pg * SLOTS + s] >= 0;
            if (nvis == count) continue;
            std::vector<int> offs = parse_page(page);
            for (size_t s = 0; s + 1 < offs.size(); s++)
                if (s >= (size_t)SLOTS || w.node_of[(size_t)pg * SLOTS + s] < 0)
                    unreached += (n_unr++ ? "," : "") + jstr(hex(page + offs[s], offs[s + 1] - offs[s]));
        }

        char created[40];
        std::time_t now = std::time(nullptr);
        std::strftime(created, sizeof created, "%Y-%m-%dT%H:%M:%S+00:00", std::gmtime(&now));
        std::string meta =
            "{\"format\":\"OpenBook Rich\",\"version\":1,"
            "\"generator\":\"ctg2obr (C++ port of build_obr.py)\","
            "\"created\":\"" + std::string(created) + "\","
            "\"source\":{\"type\":\"ctg\",\"file\":" + jstr(basename_of(ctg_path)) +
            ",\"ini\":" + ini_json(base + ".ini") +
            ",\"ctg_header_hex\":" + jstr(hex(ctg, 32)) +
            ",\"ctb_header_hex\":" + jstr(hex(ctb.data(), 12)) +
            ",\"cto_header_hex\":" + jstr(hex(book.cto.data(), 16)) +
            ",\"entries\":" + std::to_string(total_entries) + "},"
            "\"derived_fields\":{\"ctg_score10\":\"5*(2*wins_side_to_move + draws)\","
            "\"ctg_total\":\"white_wins + draws + black_wins\",\"ctg_byte31\":0,\"ctg_byte32\":0},"
            "\"exceptions\":[" + exceptions + "],"
            "\"unreached_raw\":[" + unreached + "],"
            "\"unplayable_moves\":[" + unplayable + "]}";

        uint64_t nm = w.moves.size();
        uint64_t pos_off = 64, move_off = pos_off + 48ULL * n, alias_off = move_off + 8ULL * nm,
                 meta_off = alias_off + 12ULL * na;
        Out o(tmp_path);
        o.bytes("OBR1");
        o.put(1, 2); o.put(64, 2); o.put(n, 4); o.put(nm, 4); o.put(na, 4); o.put(48, 2); o.put(8, 2);
        o.put(pos_off, 8); o.put(move_off, 8); o.put(alias_off, 8); o.put(meta_off, 8);
        o.put(meta.size(), 4); o.put(0, 4);
        uint32_t first = 0;
        for (size_t i = 0; i < n; i++) {
            if (i % 65536 == 0) report(progress, P_ALIAS + (P_TOTAL - P_ALIAS) * i / (2 * n));
            const Node& nd = w.nodes[perm[i]];
            const uint8_t* st = stats(nd);
            bool blk = nd.flags & 1;
            uint32_t a = be(st + 3, 3), b = be(st + 6, 3);
            o.put(nd.key, 8);
            o.put(be(st, 3), 4);
            o.put(blk ? b : a, 4);
            o.put(be(st + 9, 3), 4);
            o.put(blk ? a : b, 4);
            o.put(be(st + 16, 3), 4); o.put(be(st + 19, 4), 4);
            o.put(be(st + 23, 3), 4); o.put(be(st + 26, 4), 4);
            o.put(first, 4); o.put(nd.mcount, 2); o.put(st[30], 1); o.put(nd.flags, 1);
            first += nd.mcount;
        }
        for (size_t i = 0; i < n; i++) {
            if (i % 65536 == 0) report(progress, P_ALIAS + (P_TOTAL - P_ALIAS) * (n + i) / (2 * n));
            const Node& nd = w.nodes[perm[i]];
            for (int k = 0; k < nd.mcount; k++) {
                const BookMove& m = w.moves[nd.mfirst + k];
                o.put(m.pg, 2); o.put(m.annot, 1); o.put(m.status, 1);
                o.put(m.child >= 0 ? inv[m.child] : NO_CHILD, 4);
            }
        }
        for (const Alias& a : al) { o.put(a.key, 8); o.put(a.val, 4); }
        o.bytes(meta);
        o.close();
        std::error_code ec;
        std::filesystem::rename(u8(tmp_path), u8(out_path), ec);
        if (ec) throw std::runtime_error("cannot replace " + out_path + ": " + ec.message());
        char summary[512];
        std::snprintf(summary, sizeof summary,
                      "positions %zu, moves %llu, aliases %zu, alias key clashes dropped %zu, exceptions %zu, "
                      "unreached %zu, unplayable moves %zu, CTG entries %llu; walk: undecodable %llu, "
                      "illegal %llu, child missing %llu, key mismatches %llu",
                      n, (unsigned long long)nm, na, clashes, n_exc, n_unr, n_unpl,
                      (unsigned long long)total_entries, (unsigned long long)w.undecodable,
                      (unsigned long long)w.illegal, (unsigned long long)w.child_missing,
                      (unsigned long long)mismatch);
        result = summary;
        return true;
    } catch (const Cancelled&) {
        result.clear();
    } catch (const std::exception& e) {
        result = e.what();
    }
    std::error_code ec;
    std::filesystem::remove(u8(tmp_path), ec);
    return false;
}
