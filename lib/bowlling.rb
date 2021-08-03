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
    #2投分のデータが入っているか、1投目がストライクだったら、1フレーム分のスコアとして全体に追加する
    if @temp.size == 2 || strike?(@temp)
        @scores << @temp
        @temp = []
    end
end

#スコアの合計を計算する
def calc_score
    @scores.each.with_index(1) do |score, index|
    #最終フレーム以外でのスペアなら、スコアにボーナスを含めて合計する
    if score?(score) && not_last_frame?(index)
        #次のフレームもストライクで、なおかつ最終フレーム以外なら、
        #もう一つ次のフレームの一投目をボーナスの対象にする
        if strike?(@scores[index]) && not_last_frame?(index + 1)
            @total_score += 20 + @scores[index + 1].first
        else
            @total_score += 10 + @scores[index].inject(:+)
        end
        #最終フレーム以外でのスペアなら、スコアにボーナスを含めて合計する
    elsif spare?(score) && not_last_frame?(index)
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

#ストライクかどうか判定する
def strike?(score)
    score.first == 10
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
    context "ストライクを取った場合" do
        it "ストライクボーナスが加算されること" do
            #第一フレームでストライク
            @game.add_score(5)
            @game.add_score(4)
            #以降は全てガター
            add_many_scores(16, 0)
            #合計を計算
            @game.calc_score
            #期待する合計 ※()内はボーナス点
            #10 + 5 + (5) + 4 + (4) = 28
            expect(@game.total_score).to eq 28
        end
    end
    context "ダブルを取った場合" do
        it "それぞれのストライクボーナスが加算されること" do
            #第一フレームでストライク
            @game.add_score(10)
            #第二フレームもストライク
            @game.add_score(10)
            #第三フレームで5点,4点
            @game.add_score(5)
            @game.add_score(4)
            #以降は全てガター
            add_many_scores(14,0)
            #合計を計算
            @game.calc_score
            #期待する合計 ※()内はボーナス点
            #10 + 10 + (10) + 5 + (5 + 5) + 4 + (4) = 53
            expect(@game.total_score).to eq 53
        end
    end
    context "ターキーを取った場合" do
        it "それぞれのストライクボーナスが加算されること" do
            #第一フレームでストライク
            @game.add_score(10)
            #第二フレームもストライク
            @game.add_score(10)
            #第三フレームもストライク
            @game.add_score(10)
            #第四フレームで5点,4点
            @game.add_score(5)
            @game.add_score(4)
            #以降は全てガター
            add_many_scores(12,0)
            #合計を計算
            @game.calc_score
            #期待する合計 ※()内はボーナス点
            #10 + 10 + (10) + 10 + (10 + 10) + 5 + (5 + 5) + 4 + (4) = 83
            expect(@game.total_score).to eq 83
        end
    end
    context "最終フレームでストライクを取った場合" do
        it "ストライクボーナスが加算されないこと" do
            #第一フレームでストライク
            @game.add_score(10)
            #第二フレームで5点,4点
            @game.add_score(5)
            @game.add_score(4)
            #3～9フレームは全てガター
            add_many_scores(14,0)
            #最終フレームでストライク
            @game.add_score(10)
            #合計を計算
            @game.calc_score
            #期待する合計 ※()内はボーナス点
            #10 + 5 + (5) + 4 + (4) + 10 = 38
            expect(@game.total_score).to eq 38
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
    