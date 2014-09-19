#
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'tmpdir'
require 'chef/util/path_helper'
require 'spec_helper'

shared_context "a directory" do
  let(:files) { ["some.rb", "file.txt", "names.pem"] }
  let(:dir) { Dir.mktmpdir(dirname) }

  before do
    files.each { |file| File.new(File.join(dir, file), 'w').close }
  end

  after do
    File.unlink( *files.map { |file| File.join(dir, file) } )
    FileUtils.remove_entry(dir)
  end
end

describe Chef::Util::PathHelper do
  PathHelper = Chef::Util::PathHelper

  describe "escape_glob" do
    include_context "a directory" do
      let(:dirname) { "\\silly[dir]" }

      it "escapes the glob metacharacters so globbing succeeds" do
        pattern = File.join(PathHelper.escape_glob(dir), "*")
        Dir.glob(pattern).map { |x| File.basename(x) }.should match_array(files)
      end
    end
  end

  describe "glob" do
    include_context "a directory" do
      let(:dirname) { "some_dir" }

      it "joins the globbed pattern before globbing" do
        pattern = dir.split(File::SEPARATOR) + ["*", {:flags => File::FNM_DOTMATCH}]
        PathHelper.glob(*pattern).map { |x| File.basename(x) }.should match_array(files + [".", ".."])
      end
    end
  end
end
