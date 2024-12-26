package logger

import (
	"log/syslog"
)

type Logger struct {
    syslog *syslog.Writer
}
