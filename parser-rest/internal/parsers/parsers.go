package parsers

import (
	"errors"
	"fmt"

	parsec "github.com/prataprc/goparsec"
)

type ElementaryParser struct {
	parserType string
	Value      string
}

func ApplyStringParser(parser ElementaryParser, targetValue string) (string, error) {
	scanner := parsec.NewScanner([]byte(targetValue))
	ok, _ := scanner.MatchString(parser.Value)

	if ok {
		return parser.Value, nil
	}

	return "", errors.New(fmt.Sprintf("failed to parse string '%s'", parser.Value))
}
