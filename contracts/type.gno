package autoswap

import (
	"gno.land/p/demo/avl"
)

type Vault struct {
	balances *avl.Tree // address -> *uint256.Uint
	paused   bool
	token0   string
	token1   string
	fee      uint32
	width    uint32
}
