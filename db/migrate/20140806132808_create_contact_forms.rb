class CreateContactForms < ActiveRecord::Migration
  def change
    create_table :contact_forms do |t|
      t.string :name
      t.sting :email
      t.text :message
      t.string :status

      t.timestamps
    end
  end
end
