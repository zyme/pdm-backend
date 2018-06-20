# frozen_string_literal: true

require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  include ResourceTestHelper
  test 'Can create new document' do
    p = profiles(:harrys_profile)
    create_new_success(Document, p, read_test_file("documents/document_reference_good.json"))
  end
end
