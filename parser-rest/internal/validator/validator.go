package validator

type Validator struct {
	Errors []ValidationError
}

type ValidationError struct {
	Key     string
	Message string
}

func New() *Validator {
	return &Validator{Errors: make([]ValidationError, 0)}
}

func (v *Validator) Valid() bool {
	return len(v.Errors) == 0
}

func (v *Validator) Check(ok bool, key string, message string) {
	if !ok {
		v.AddError(key, message)
	}
}

func (v *Validator) AddError(key, message string) {
	v.Errors = append(v.Errors, ValidationError{Key: key, Message: message})
}
