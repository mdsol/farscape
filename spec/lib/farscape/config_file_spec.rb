require 'spec_helper'
require 'tempfile'


describe Farscape::ConfigFile do
  shared_examples_for 'provides the default configuration' do
    it 'provides a hash with configuration keys' do
      expect(configuration).to be_instance_of(Hash)
    end

    it 'provides the default accept header configuration' do
      expect(configuration[:default_accept]).to eq('application/vnd.hale+json')
    end
  end

  describe '#configuration' do
    subject(:configuration) {Farscape::ConfigFile.new.configuration}

    context 'without any configuration file' do
      it_behaves_like 'provides the default configuration'
    end

    context 'with a no valid configuration file' do
      before do
        @file = Tempfile.new('broken_configuration')
        @file.write("Iam \n not valid \n   yaml")
        stub_const('Farscape::CONFIGURATION_FILE_PATH', @file.path)
      end
      after do
        @file.close
        @file.unlink
      end
      it_behaves_like 'provides the default configuration'
    end

    context 'with a valid configuration file' do
      before do
        @file = Tempfile.new('working_configuration')
        @file.write('cool_key: cool_value')
        @file.flush
        stub_const('Farscape::CONFIGURATION_FILE_PATH', @file.path)
      end
      after do
        @file.close
        @file.unlink
      end
      it 'reads the keys of the file' do
        expect(configuration[:cool_key]).to eq('cool_value')
      end
    end

  end

end