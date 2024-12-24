package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"k8s.io/klog/v2"
	ctlutil "k8s.io/kubectl/pkg/cmd/util"
	"k8s.io/kubectl/pkg/util/i18n"
	"k8s.io/kubectl/pkg/util/templates"

	"github.com/kosmos.io/netdoctor/pkg/command/share"
	"github.com/kosmos.io/netdoctor/pkg/utils"
)

var initExample = templates.Examples(i18n.T(`
        # Init netdoctor config, e.g:
        netdoctor init 
`))

type InitOptions struct {
}

func NewInitCmd() *cobra.Command {
	o := &InitOptions{}
	cmd := &cobra.Command{
		Use:                   "init",
		Short:                 i18n.T("init netdoctor config"),
		Long:                  "",
		Example:               initExample,
		SilenceUsage:          true,
		DisableFlagsInUseLine: true,
		RunE: func(cmd *cobra.Command, args []string) error {
			ctlutil.CheckErr(o.Run())
			return nil
		},
		Args: func(cmd *cobra.Command, args []string) error {
			for _, arg := range args {
				if len(arg) > 0 {
					return fmt.Errorf("%q does not take any arguments, got %q", cmd.CommandPath(), args)
				}
			}
			return nil
		},
	}
	return cmd
}

func (o *InitOptions) Run() error {
	doOptions := share.CreateDefaultOptions()
	if err := utils.WriteOpt(doOptions); err != nil {
		klog.Fatal(err)
	} else {
		klog.Info("write opts success")
	}
	return nil
}
