package agent

type CommandExecution struct {
    Command   string   `json:"command"`
    Arguments []string `json:"arguments,omitempty"`
}
