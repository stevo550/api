begin
  init_settings = Setting.table_exists?
  if init_settings
    Dir[Rails.root.join 'app', 'models', 'setting', '*.rb'].each do |setting_model|
      require_dependency setting_model
    end
    Setting.descendants.each(&:load_defaults)
  end
rescue
  false
end

begin
  init_product_types = ProductType.table_exists?
  if init_product_types
    Dir[Rails.root.join 'app', 'models', 'product_type', '*.rb'].each do |product_type_model|
      #next if 'ProductType::Demo' == product_type_model.to_s && !Rails.env.development?
      require_dependency product_type_model
    end
    ProductType.descendants.each(&:load_product_types)
  end
rescue
  false
end

# Include demo support code in development
if Rails.env.development?
  Dir[Rails.root.join 'app', 'models', 'null', '*.rb'].each do |null_model|
    require_dependency null_model
  end

  require 'jellyfish/demo'
end