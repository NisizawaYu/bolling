# ボウリングのスコアを管理するクラス
class Bowling
#インスタンスを生成する時に処理が実行される
def initialize
    #スコアの合計
    @total_score = 0
    #scores = []
    #一時保存用の配列
    @temp = []
end

#スコアの合計を返す
def total_score
    @total_score
end

#スコアを追加する
def add_score(pins)
    #一時保存用のスコアに、倒したピンの数を追加する
    @temp << pins
    #2投分のデータが入っていれば、1フレーム分のスコアとして全体に追加する
    if @temp.size == 2
        @scores << @temp
        @temp = []
    end
end

#スコアの合計を計算する
def calc_score
    @scores.each.with_index(1) do |score, index|
    #最終フレーム以外でのスペアなら、スコアにボーナスを含めて合計する
    if score?(score) && not_last_frame?(index)
        @total_score += calc_spare_bonus(index)
    else
        @total_score += score.inject(:+)
    end
end
end
end

private
#スペアかどうか判定する
def spare?(score)
    score.inject(:+) == 10
end

#最終フレームかどうか判定する
def not_last_frame?(index)
    index < 10
end

#スペアボーナスを含んだ値でスコアを計算する
def calc_spare_bonus(index)
    10 + @scores[index].first
end
    
require "bowling"
describe "ボウリングのスコア計算" do
    #インスタンスの生成を共通化
    before do
        @game = Bolling.new
    end
    describe "全体の合計" do
        context "全ての投球がガターだった場合" do
            it "0になること" do
                add_many_scores(20, 0)
                #合計を計算
                @game.calc_score
                expect(@game.total_score).to eq 0
            
        end
    end
    context "全ての投球で1ピンずつ倒した場合" do
        it "20になること" do
        add_many_scores(20, 1)
        #合計を計算
        @game.calc_score
        expect(@game.total_score).to eq 20
        end
    end
    context "スペアを取った場合" do
        it "スペアボーナスが加算されること" do
            #第一フレームで3点,7点のスペア
            @game.add_score(3)
            @game.add_score(7)
            #第二フレームの一投目で4点
            @game.add_score(4)
            #以降は全てガター
            add_many_scores(17,0)
            #合計を計算
            @game.calc_score
            #期待する合計 ※()内はボーナス点
            #3 + 7 + 4 + (4) = 18
            expect(@game.total_score).to eq 18
        end
    end
    context "フレーム違いでスペアになるようなスコアだった場合" do
        it "スペアボーナスが加算されないこと" do
            #第一フレームで3点,5点
            @game.add_score(3)
            @game.add_score(5)
            #第二フレームで5点,4点
            @game.add_score(5)
            @game.add_score(4)
            #以降は全てガター
            add_many_scores(16,0)
            #合計を計算
            @game.calc_score
            #期待する合計
            #3 + 5 + 5 + 4 = 17
            expect(@game.total_score).to eq 17
        end
    end
    context "最終フレームでスペアを取った場合" do
        it "スペアボーナスが加算されないこと" do
            #第一フレームで3点,7点のスペア
            @game.add_score(3)
            @game.add_score(7)
            #第二フレームの一投目で4点
            @game.add_score(4)
            #15球は全てガター
            add_many_scores(15,0)
            #最終フレームで3点,7点のスペア
            @game.add_score(3)
            @game.add_score(7)
            #合計を計算
            @game.calc_score
            #期待する合計 ※()内はボーナス点
            #3 + 7 + 4 + (4) + 3 + 7 = 28
            expect(@game.total_score).to eq 28
        end
    end
end
end
private
# 複数回のスコア追加をまとめて実行する
def add_many_scores(count, pins)
    count.times do
        @game.add_score(pins)
    end
end
    