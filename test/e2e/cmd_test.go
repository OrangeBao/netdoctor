package e2e

import (
	"github.com/kosmos.io/netdoctor/pkg/command/share"
	"github.com/kosmos.io/netdoctor/pkg/utils"
	"github.com/kosmos.io/netdoctor/test/e2e/framework"
	"github.com/onsi/ginkgo/v2"
	"github.com/onsi/gomega"
)

var _ = ginkgo.Describe("netdoctor testing", func() {
	ginkgo.Context("netctl help", func() {

		ginkgo.It("netctl help", func() {
			err := framework.ExecCommand("help")
			gomega.Expect(err).NotTo(gomega.HaveOccurred())
		})

		ginkgo.It("netctl init", func() {
			err := framework.ExecCommand("init")
			gomega.Expect(err).NotTo(gomega.HaveOccurred())

			// Check if the json file format is correct
			defaultOptions := share.CreateDefaultOptions()

			readOptions := &share.DoOptions{}

			err = utils.ReadOpt(readOptions)
			gomega.Expect(err).NotTo(gomega.HaveOccurred())

			gomega.Expect(readOptions.Equal(defaultOptions)).To(gomega.BeTrue(), "readOptions and defaultOptions should be the same")
		})
	})
})
