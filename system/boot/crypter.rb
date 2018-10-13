Sepass::Container.boot :crypter do |system|
  init do
    require 'symmetric-encryption'

    use :settings

    SymmetricEncryption.cipher = SymmetricEncryption::Cipher.new(
      key:          system['settings'].secret_encoding_key,
      cipher_name: 'aes-256-cbc'
    )
  end

  start do
    register 'crypter', SymmetricEncryption 
  end
end
