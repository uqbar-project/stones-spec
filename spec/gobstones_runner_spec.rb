# encoding: UTF-8

require_relative './spec_helper'
require 'yaml'

require_relative '../lib/stones-spec'

include StonesSpec

describe Runner do
  describe Language::Gobstones do
    let(:lang) { Language::Gobstones }
    let(:command) { 'python .heroku/vendor/pygobstones-lang/pygobstoneslang.py' }
    let(:runner) { Runner.new(lang, command) }
    let(:test_definition) { YAML.load_file "spec/data/#{test_file}.yml" }
    let(:results) { runner.run! test_definition }
    let(:all_htmls) { results.map { |it| it[1] } }
    let(:html) { all_htmls[0] }
    let(:title) { results.map { |it| it[0] } }

    describe 'xgobstones' do
      describe 'lists' do
        context 'when passes' do
          let(:test_file) { 'xgobstones/function/list_reverse_ok' }
          it { expect(all_examples :passed).to be true }
        end

        context 'when fails' do
          let(:test_file) { 'xgobstones/function/list_reverse_fail' }
          it { expect(all_examples :failed).to be true }
          it { expect(html).to include 'Se esperaba <b>[4, 3, 2, 1]</b> pero se obtuvo <b>[1, 2, 3, 4]</b>' }
        end
      end
    end

    describe 'procedure spec' do
      context 'when passes' do
        let(:test_file) { 'gobstones/procedure/move_to_origin_ok' }
        it { expect(all_examples :passed).to be true }
      end

      context 'when passes with arguments' do
        let(:test_file) { 'gobstones/procedure/times_move_ok' }
        it {expect(all_examples :passed).to be true }
      end

      context 'when fails' do
        let(:test_file) { 'gobstones/procedure/move_to_origin_fail' }
        it { expect(all_examples :failed).to be true }
      end

      context 'when fails with arguments' do
        let(:test_file) { 'gobstones/procedure/times_move_fail' }
        it { expect(all_examples :failed).to be true }
      end

      context 'when no title is given, it uses the procedure name and the arguments' do
        let(:test_file) { 'gobstones/procedure/times_move_ok' }
        it { expect(title).to include '<h3>TimesMove(3, Sur)</h3>' }
        it { expect(title).to include '<h3>TimesMove(2, Este)</h3>' }
      end
    end

    describe 'function spec' do
      context 'when passes with args' do
        let(:test_file) { 'gobstones/function/remaining_cells_ok' }
        it {expect(all_examples :passed).to be true }
      end

      context 'when fails with args' do
        let(:test_file) { 'gobstones/function/remaining_cells_fail' }

        it { expect(all_examples :failed).to be true }
        it { expect(html).to include 'Se esperaba <b>9</b> pero se obtuvo <b>18</b>' }
      end
    end

    describe 'program spec' do
      context 'when the program is empty' do
        let(:test_file) { 'empty_program' }
        it { expect(html).to include 'No es posible ejecutar un programa vacío' }
      end

      context 'can check head position' do
        context 'when its wrong' do
          let(:test_file) { 'head_position_wrong' }
          it { expect(all_examples :failed).to be true }
        end

        context 'when its ok' do
          let(:test_file) { 'head_position_ok' }
          it { expect(all_examples :passed).to be true }
        end
      end

      context 'when a title is given' do
        context 'and the test passes' do
          let(:test_file) { 'red_ball_at_origin' }
          it { expect(title).to include '<h3>A red ball</h3>' }
        end

        context 'and the test fails' do
          let(:test_file) { 'red_ball_at_origin_wrong' }
          it { expect(title).to include '<h3>A red ball</h3>' }
        end

        context 'and syntax errors are present' do
          let(:test_file) { 'syntax_error' }
          it { expect(title).not_to include '<h3>A syntax error</h3>' }
        end

        context 'and a runtime error occurs' do
          let(:test_file) { 'runtime_error' }
          it { expect(title).to include '<h3>A runtime error</h3>' }
        end
      end

      context 'when a title is not given' do
        context 'and the test passes' do
          let(:test_file) { 'red_ball_at_origin_without_title' }
          it { expect(title).not_to include '<h3></h3>' }
        end

        context 'and a runtime error occurs' do
          let(:test_file) { 'runtime_error_without_title' }
          it { expect(title).not_to include '<h3></h3>' }
        end
      end

      context 'doesnt check head position if the flag is false' do
        let(:test_file) { 'dont_check_head_position' }
        it { expect(all_examples :passed).to be true }
      end

      context 'doesnt include the initial board if the flag is false' do
        let(:test_file) { 'red_ball_at_origin_without_initial_board' }
        it { expect(html).not_to include(File.new('spec/data/red_ball_at_origin_initial.html').read) }
      end

      context 'when the file is sintactically ok' do
        context 'when the final board matches' do
          let(:test_file) { 'red_ball_at_origin' }

          it { expect(all_examples :passed).to be true }

          context 'should return an html representation of the initial and final board as result' do
            it { expect(html).to include(File.new('spec/data/red_ball_at_origin_initial.html').read) }
            it { expect(html).to include(File.new('spec/data/red_ball_at_origin.html').read) }
            it { expect(html).to start_with('<div>') }
            it { expect(html).to end_with('</div>') }
          end
        end

        context 'when the final board doesnt match' do
          let(:test_file) { 'red_ball_at_origin_wrong' }
          it { expect(all_examples :failed).to be true }

          context 'should return an html representation of the initial, expected and actual boards as result' do
            it { expect(html).to include(File.new('spec/data/red_ball_at_origin_initial.html').read) }
            it { expect(html).to include(File.new('spec/data/red_ball_at_origin_wrong.html').read) }
            it { expect(html).to include(File.new('spec/data/red_ball_at_origin_expected.html').read) }
            it { expect(html).to start_with('<div>') }
            it { expect(html).to end_with('</div>') }
          end
        end

        context 'when produces BOOM' do
          let(:test_file) { 'runtime_error' }

          it { expect(all_examples :failed).to be true }

          it { expect(all_htmls.join("\n")).to include(File.new('spec/data/runtime_error_initial.html').read) }
          it do
            expect(all_htmls.join("\n")).to include(
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
        let(:test_file) { 'syntax_error' }

        it { expect(results[1]).to eql :errored }
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

  def all_examples status
    results.all? {|result| result[2].eql? status}
  end

end
