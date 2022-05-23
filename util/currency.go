package util

// Constants for supported currencies
const (
	USD = "USD"
	EUR = "EUR"
	CAD = "CAD"
)

// returns true if input is a supported currency
func IsSupportedCurrency(currency string) bool {
	switch currency {
	case USD, EUR, CAD:
		return true
	}
	return false
}
