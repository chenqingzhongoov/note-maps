# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

flutter_find_srcs = $(shell find $(1) -name '*.dart') $(1)/pubspec.yaml

define flutter_pub_get =
	cd $(dir $@) && flutter pub get
	touch $@
endef

define flutter_format =
	cd $(dir $@) && flutter format $?
	touch $@
endef

define flutter_lint =
	cd $(dir $@) && flutter analyze
	touch $@
endef

define flutter_build =
	cd $(dir $@) ; flutter build $(subst .,,$(suffix $@))
	touch $@
endef

define flutter_test =
	cd $(dir $@) && flutter --no-pub test
	touch $@
endef
