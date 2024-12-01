package data

type ProblemDetail struct {
	Status     int                      `json:"status"`
	Type       string                   `json:"type"`
	Title      string                   `json:"title"`
	Detail     string                   `json:"detail"`
	Violations []ProblemDetailViolation `json:"violations"`
}

type ProblemDetailViolation struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}
