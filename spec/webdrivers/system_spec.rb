# frozen_string_literal: true

require 'spec_helper'

wsl_proc_contents = [
  'Linux version 4.4.0-18362-Microsoft',
  '(Microsoft@Microsoft.com)',
  '(gcc version 5.4.0 (GCC) )',
  '#836-Microsoft',
  'Mon May 05 16:04:00 PST 2020'
].join ' '

describe Webdrivers::System do
  describe '#wsl?' do
    context 'when the current platform is linux' do
      before { allow(described_class).to receive(:platform).and_return 'linux' }

      it 'checks /proc/version' do
        allow(File).to receive(:open).with('/proc/version').and_return(StringIO.new(wsl_proc_contents))

        expect(described_class.wsl?).to eq true
      end
    end

    context 'when the current platform is mac' do
      before { allow(described_class).to receive(:platform).and_return 'mac' }

      it 'does not bother checking proc' do
        allow(File).to receive(:open).and_call_original

        expect(described_class.wsl?).to eq false

        expect(File).not_to have_received(:open).with('/proc/version')
      end
    end
  end

  describe '#to_win32_path' do
    before { allow(described_class).to receive(:call).and_return("C:\\path\\to\\folder\n") }

    it 'uses wslpath' do
      described_class.to_win32_path '/c/path/to/folder'

      expect(described_class).to have_received(:call).with('wslpath -w \'/c/path/to/folder\'')
    end

    it 'removes the trailing newline' do
      expect(described_class.to_win32_path('/c/path/to/folder')).not_to end_with('\n')
    end

    context 'when the path is already in Windows format' do
      it 'returns early' do
        expect(described_class.to_win32_path('D:\\')).to eq 'D:\\'

        expect(described_class).not_to have_received(:call)
      end
    end
  end

  describe '#to_wsl_path' do
    before { allow(described_class).to receive(:call).and_return("/c/path/to/folder\n") }

    it 'uses wslpath' do
      described_class.to_wsl_path 'C:\\path\\to\\folder'

      expect(described_class).to have_received(:call).with('wslpath -u \'C:\\path\\to\\folder\'')
    end

    it 'removes the trailing newline' do
      expect(described_class.to_wsl_path('/c/path/to/folder')).not_to end_with('\n')
    end
  end
end
