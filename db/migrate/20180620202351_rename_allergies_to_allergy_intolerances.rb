class RenameAllergiesToAllergyIntolerances < ActiveRecord::Migration[5.2]
  def change
    rename_table :allergies, :allergy_intolerances
  end
end
