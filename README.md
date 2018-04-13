# Overview
This repository contains the source code of a single terraform module which
has been migrated from the terraform-infrastructure repository:
https://git.reform.hmcts.net/devops/terraform-infrastructure/tree/master/main-environment/modules/vm-managed-disk

# Versions
At the time of the transition there are different users of this module in
terraform-infrastructure. Different users of this module work with different
versions as changes in the module and in the code using the module are not in
sync. For this reason special old versions of this module have been added here,
such as /module_v01. These old versions are only intended to be used by
specific projects in terraform-infrastructure which have not been updated to
work with the latest version of the module. The default code for the module
is located in the "module" directory and it is the version that will be updated
and maintained on the long term. It is recommended for users of this module to
use references in the source of the module (reference can be tags or commits)
so the code sticks to a particular version of the module which is know to work.
This way it is possible to make code changes in this module with no risk to
break other code.
