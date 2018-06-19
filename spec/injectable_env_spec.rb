# encoding: utf-8
require './lib/injectable_env'
require 'yaml'
require 'tempfile'

RSpec.describe InjectableEnv do

  Placeholder = '{{REACT_APP_VARS_AS_JSON______________________________________________________________________________________________________}}'
  UnpaddedPlaceholder = '{{REACT_APP_VARS_AS_JSON}}'

  describe '.create' do
    it "returns empty object" do
      expect(InjectableEnv.create).to eq('{}')
    end

    describe 'for REACT_APP_ vars' do
      before do
        ENV['REACT_APP_HELLO'] = 'Hello World'
        ENV['REACT_APP_EMOJI'] = '🍒🍊🍍'
        ENV['REACT_APP_EMBEDDED_QUOTES'] = '"e=MC(2)"'
        ENV['REACT_APP_SLASH_CONTENT'] = '\\'
        ENV['REACT_APP_NEWLINE'] = "I am\na poet."
      end
      after do
        ENV.delete 'REACT_APP_HELLO'
        ENV.delete 'REACT_APP_EMOJI'
        ENV.delete 'REACT_APP_EMBEDDED_QUOTES'
        ENV.delete 'REACT_APP_SLASH_CONTENT'
        ENV.delete 'REACT_APP_NEWLINE'
      end

      it "returns entries" do
        result = InjectableEnv.create
        # puts result
        # puts unescape(result)
        object = JSON.parse(unescape(result))
        expect(object['REACT_APP_HELLO']).to eq('Hello World')
        expect(object['REACT_APP_EMOJI']).to eq('🍒🍊🍍')
        expect(object['REACT_APP_EMBEDDED_QUOTES']).to eq('"e=MC(2)"')
        expect(object['REACT_APP_SLASH_CONTENT']).to eq('\\')
        expect(object['REACT_APP_NEWLINE']).to eq("I am\na poet.")
      end
    end

    describe 'for unmatches vars' do
      before do
        ENV['ANOTHER_HELLO'] = 'Hello World'
      end
      after do
        ENV.delete 'ANOTHER_HELLO'
      end

      it "ignores them" do
        result = InjectableEnv.create
        object = JSON.parse(unescape(result))
        expect(object).not_to have_key('ANOTHER_HELLO')
      end
    end
  end

  describe '.render' do
    it "writes result to stdout" do
      expect { InjectableEnv.render }.to output('{}').to_stdout
    end
  end

  describe '.replace' do
    before do
      ENV['REACT_APP_HELLO'] = "Hello\n\"World\" we \\ prices today 🌞"
    end
    after do
      ENV.delete 'REACT_APP_HELLO'
    end

    it "writes into file" do
      begin
        file = Tempfile.new('injectable_env_test')
        file.write(%{var injected="#{Placeholder}"})
        file.rewind

        InjectableEnv.replace(file.path)

        expected_value='var injected="{\\"REACT_APP_HELLO\\":\\"Hello\\\\n\\\\\"World\\\\\" we \\\\\\\\ prices today 🌞\\"}'
        actual_value=file.read
        expect(actual_value.index(expected_value)).to eq(0)
        # Closing double-quote is padded out but still last char.
        actual_size = actual_value.size
        expect(actual_value.index(/\"\Z/)).to eq(actual_size-1)
      ensure
        if file
          file.close
          file.unlink
        end
      end
    end

    it "matches unpadded placeholder" do
      begin
        file = Tempfile.new('injectable_env_test')
        file.write(%{var injected="#{UnpaddedPlaceholder}"})
        file.rewind

        InjectableEnv.replace(file.path)

        expected_value='var injected="{\\"REACT_APP_HELLO\\":\\"Hello\\\\n\\\\\"World\\\\\" we \\\\\\\\ prices today 🌞\\"}'
        actual_value=file.read
        expect(actual_value.index(expected_value)).to eq(0)
        # Closing double-quote is padded out but still last char.
        actual_size = actual_value.size
        expect(actual_value.index(/\"\Z/)).to eq(actual_size-1)
      ensure
        if file
          file.close
          file.unlink
        end
      end
    end

    it "preserves character length of bundle" do
      begin
        placeholder_size = Placeholder.size
        file = Tempfile.new('injectable_env_test')
        file.write(Placeholder)
        file.rewind

        InjectableEnv.replace(file.path)

        expected_value = '{\\"REACT_APP_HELLO\\":\\"Hello\\\\n\\\\\"World\\\\\" we \\\\\\\\ prices today 🌞\\"}'
        actual_value = file.read
        replaced_size = actual_value.size
        expect(replaced_size).to eq(placeholder_size)
        expect(actual_value.index(expected_value)).to eq(0)
      ensure
        if file
          file.close
          file.unlink
        end
      end
    end

    it "does not write when the placeholder is missing" do
      begin
        file = Tempfile.new('injectable_env_test')
        file.write('template is not present in file')
        file.rewind

        InjectableEnv.replace(file.path)

        expected_value='template is not present in file'
        actual_value=file.read
        expect(actual_value).to eq(expected_value)
      ensure
        if file
          file.close
          file.unlink
        end
      end
    end
  end

  describe '.escape' do
    it 'slash-escapes the JSON token double-quotes' do
      expect(InjectableEnv.escape('value')).to eq('\\"value\\"')
    end
    it 'double-escapes double-quotes in the value' do
      # This looks insane, but the six-slashes '\\\\\\' test for three '\\\'
      expect(InjectableEnv.escape('"quoted"')).to eq('\\"\\\\\\"quoted\\\\\\"\\"')
    end
  end
end

# For the sake of parsing the test output, 
# undo the "injectable" JSON escape sequences.
def unescape(s)
  YAML.load(%Q(---\n"#{s}"\n))
end