package autoswap

import (
	"std"
	"testing"
)

func TestRegisterGRC20InterfaceNotAsAdmin(t *testing.T) {
	std.TestSetRealm(fresh02Realm)

	shouldPanic(t, func() {
		RegisterGRC20Interface("pkgPath", FooToken{})
	})
}

func TestRegisterGRC20Interface(t *testing.T) {
	RegisterGRC20Interface("pkgPath", FooToken{})

	grc20, found := registered.Get("pkgPath")

	shouldEQ(t, found, true)
	shouldEQ(t, grc20, FooToken{})
}

func TestRegisterGRC20InterfaceAlreadyRegistered(t *testing.T) {
	shouldPanic(t, func() {
		RegisterGRC20Interface("pkgPath", FooToken{})
	})
}

func TestUnregisterGRC20InterfaceNotAsAdmin(t *testing.T) {
	std.TestSetRealm(fresh02Realm)

	shouldPanic(t, func() {
		UnregisterGRC20Interface("pkgPath")
	})
}

func TestUnregisterGRC20Interface(t *testing.T) {
	UnregisterGRC20Interface("pkgPath")

	_, found := registered.Get("pkgPath")

	shouldEQ(t, found, false)
}

func TestUnregisterGRC20InterfaceNotRegistered(t *testing.T) {
	shouldPanic(t, func() {
		UnregisterGRC20Interface("pkgPath")
	})
}
