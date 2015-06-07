# encoding: UTF-8

require_relative './spec_helper'
require 'yaml'

require_relative '../lib/stones-spec'

include StonesSpec

describe Runner do
  describe Language::Gobstones do
    let(:lang) { Language::Gobstones }
    let(:runner) { Runner.new(lang) }

    describe 'procedure spec' do
      context 'when passes' do
        let(:results) { runner.run!(YAML.load_file 'spec/data/gobstones/procedure/move_to_origin_ok.yml') }

        it { expect(results[1]).to eq :passed }
      end
      context 'when fails' do
        let(:results) { runner.run!(YAML.load_file 'spec/data/gobstones/procedure/move_to_origin_fail.yml') }

        it { expect(results[1]).to eq :failed }
      end
    end

    describe 'program spec' do
      context 'can check head position' do
        context 'when its wrong' do
          let(:results) { runner.run!(YAML.load_file 'spec/data/head_position_wrong.yml') }
          it { expect(results[1]).to eq(:failed) }
        end

        context 'when its ok' do
          let(:results) { runner.run!(YAML.load_file 'spec/data/head_position_ok.yml') }
          it { expect(results[1]).to eq(:passed) }
        end
      end

      context 'doesnt check head position if the flag is false' do
        let(:results) { runner.run!(YAML.load_file 'spec/data/dont_check_head_position.yml') }
        it { expect(results[1]).to eq(:passed) }
      end

      context 'when the file is sintactically ok' do
        context 'when the final board matches' do
          let(:results) { runner.run!(YAML.load_file 'spec/data/red_ball_at_origin.yml') }

          it { expect(results[1]).to eq(:passed) }

          context 'should return an html representation of the board as result' do
            let(:html) { results[0] }

            it { expect(html).to include(File.new('spec/data/red_ball_at_origin.html').read) }
            it { expect(html).to start_with('<div>') }
            it { expect(html).to end_with('</div>') }
          end
        end

        context 'when the final board doesnt match' do
          let(:results) { runner.run!(YAML.load_file 'spec/data/red_ball_at_origin_wrong.yml') }
          it { expect(results[1]).to eq(:failed) }

          context 'should return an html representation of the initial, expected and actual boards as result' do
            let(:html) { results[0] }

            it { expect(html).to include(File.new('spec/data/red_ball_at_origin_initial.html').read) }
            it { expect(html).to include(File.new('spec/data/red_ball_at_origin_wrong.html').read) }
            it { expect(html).to include(File.new('spec/data/red_ball_at_origin_expected.html').read) }
            it { expect(html).to start_with('<div>') }
            it { expect(html).to end_with('</div>') }
          end
        end

        context 'when produces BOOM' do
          let(:results) { runner.run!(YAML.load_file 'spec/data/runtime_error.yml') }
          it { expect(results[1]).to eq(:failed) }
          it do
            expect(results[0]).to eq(
'<pre>cerca de invocación a procedimiento
  |
  V
  Mover(Este)

--

Error en tiempo de ejecución:

    No se puede mover el cabezal en dirección: Este
    La posición cae afuera del tablero</pre>')
          end
        end
      end

      context 'when the file is not sintactically ok,' do
        let(:results) { runner.run!(YAML.load_file 'spec/data/syntax_error.yml') }
        it { expect(results[1]).to eq(:failed) }
        it do
          expect(results[0]).to eq(
'<pre>cerca de un identificador con mayúscula "Error"
        |
        V
  Poner(Error)

--

Error en el programa:

    El tipo Error no está definido</pre>')
        end
      end
    end
  end
end
