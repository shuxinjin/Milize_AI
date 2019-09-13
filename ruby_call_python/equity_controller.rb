require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'json'
require 'active_record'
require 'yaml'
require 'time'
require 'cgi'
require 'csv'
require 'logger'

class EquityController < ApplicationController
  before_action :require_loggedin, only: %i(index mktranking stgranking stgranking recranking)

  if Rails.env.production?
    API_SERVER_URL = "http://39.110.206.173/kabuapi/api"
  else
    API_SERVER_URL = "http://192.168.1.100/kabuapi/api"
  end
  #API_SERVER_URL = "http://192.168.1.100/kabuapi/api"

  ###ストラテジートップ10
  def index
    @stgRankBuy = []
    @stgRankSell = []
    @newsList = []

    #--- 本日の買いストラテジー トップ１０

    # top = EqJsonList.where(["js_key = 'StrategyByTicker/TodayBuyStrategyTop10.json'"]).first
    # tmp = EqJsonData.where(["js_date = ? and js_key = 'StrategyByTicker/TodayBuyStrategyTop10.json' and js_d_key in ('market_ticker_code','total_return','strategy_name','mkt_ticker_name','strategy_id')",top["js_date"]]).order("js_seq")
    # nowIdx = -1
    # tmp.each do |d|
    #   if nowIdx != d["js_seq"] then
    #     @stgRankBuy << {}
    #     nowIdx = d["js_seq"]
    #   end
    #   @stgRankBuy[nowIdx].store(d["js_d_key"],d["js_d_value"])
    # end

    #WebAPIから取得する
    #http://39.110.206.173/kabuapi/api/StrategyByTicker/TodayBuyStrategyTop10.json
    @stgRankBuy = GetJsonData(API_SERVER_URL + '/StrategyByTicker/TodayBuyStrategyTop10.json')

    #--- 本日の売りストラテジー トップ１０
    # #top = EqJsonList.where("js_key = 'StrategyByTicker/TodaySellStrategyTop10.json'").first
    # tmp = EqJsonData.where(["js_date = ? and js_key = 'StrategyByTicker/TodaySellStrategyTop10.json' and js_d_key in ('market_ticker_code','total_return','strategy_name','mkt_ticker_name','strategy_id')",top["js_date"]]).order("js_seq")
    # nowIdx = -1
    # tmp.each do |d|
    #   if nowIdx != d["js_seq"] then
    #     @stgRankSell << {}
    #     nowIdx = d["js_seq"]
    #   end
    #   @stgRankSell[nowIdx].store(d["js_d_key"],d["js_d_value"])
    # end

    #WebAPIから取得する
    #http://39.110.206.173/kabuapi/api//StrategyByTicker/TodaySellStrategyTop10.json
    @stgRankSell = GetJsonData(API_SERVER_URL + '/StrategyByTicker/TodaySellStrategyTop10.json')

    #---最新のニュース（5件）
    # top = EqJsonList.where("js_key = 'News/LatestNews5.json'").first
    # tmp = EqJsonData.where(["js_date = ? and js_key = 'News/LatestNews5.json'",top["js_date"]]).order("js_seq")
    # nowIdx = -1
    # tmp.each do |d|
    #   if nowIdx != d["js_seq"] then
    #     @newsList << {}
    #     nowIdx = d["js_seq"]
    #   end
    #   @newsList[nowIdx].store(d["js_d_key"],d["js_d_value"])
    # end

    #http://39.110.206.173/kabuapi/api/News/LatestNews5.json
    @newsList = GetJsonData(API_SERVER_URL + '/News/LatestNews5.json')

    tmp = SecuritiesPrice.where(["sec_code = ? and pdate >= DATE_ADD(now(), INTERVAL -1 YEAR)",@stgRankBuy[0]["market_ticker_code"]]).order("pdate")
    pd = []
    pv = []
    pclose = []
    tmp.each do |d|
      pd << d["pdate"]
      pclose << d["close"]
      pv << d["volume"]
    end
    @graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "買い銘柄1位の株価")
      f.subtitle(text: @stgRankBuy[0]["mkt_ticker_name"])
      f.xAxis(categories: pd,tickInterval:60)
      f.options[:yAxis] = [{ title: { text: '出来高' }}, { title: { text: '株価'}, opposite: true}]
      f.series(name: '出来高', data: pv,type: 'spline',yAxis: 0)
      f.series(name: '株価', data: pclose,type: 'spline',yAxis: 1,color: '#BF0B23')
    end

    tmp = SecuritiesPrice.where(["sec_code = ? and pdate >= DATE_ADD(now(), INTERVAL -1 YEAR)",@stgRankSell[0]["market_ticker_code"]]).order("pdate")
    pd = []
    pv = []
    pclose = []
    tmp.each do |d|
      pd << d["pdate"]
      pclose << d["close"]
      pv << d["volume"]
    end
    @graph2 = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "売り銘柄1位の株価")
      f.subtitle(text: @stgRankSell[0]["mkt_ticker_name"])
      f.xAxis(categories: pd,tickInterval:60)
      f.options[:yAxis] = [{ title: { text: '出来高' }}, { title: { text: '株価'}, opposite: true}]
      f.series(name: '出来高', data: pv,type: 'spline',yAxis: 0)
      f.series(name: '株価', data: pclose,type: 'spline',yAxis: 1,color: '#92D050')
    end
  end

  ###マーケットランキング
  def mktranking
    @rklist = {"1" => "値上がり率ランキング", "2" => "値下り率ランキング", "3" => "時価総額上位ランキング", "4" => "時価総額下位ランキング", "5" => "高PERランキング", "6" => "低PERランキング", "7" => "高PBRランキング", "8" => "低PBRランキング", "9" => "ROEランキング", "10" => "ROAランキング"}
    @mklist = []
    @seclist = []
    @rkdata = []
    tmp = EqJsonData.where(["js_key = 'MarketInfo/MarketList.json'"]).order("js_seq")
    nowIdx = -1
    tmp.each do |d|
      if nowIdx != d["js_seq"] then
        @mklist << {}
        nowIdx = d["js_seq"]
      end
      @mklist[nowIdx].store(d["js_d_key"],d["js_d_value"])

    end
    tmp = EqJsonData.where(["js_key = 'MarketInfo/SectorList.json'"]).order("js_seq")
    nowIdx = -1
    tmp.each do |d|

      if nowIdx != d["js_seq"] then
        @seclist << {}
        nowIdx = d["js_seq"]
      end
      @seclist[nowIdx].store(d["js_d_key"],d["js_d_value"])
    end

    @rkinf = []
    if params[:r] == nil then
       @rkinf << "1"
       @rkinf << @mklist[0]["instance_no"]
       @rkinf << @seclist[0]["instance_no"]
    else
       @rkinf << params[:r]
       @rkinf << params[:m]
       @rkinf << params[:s]
    end

    # http://39.110.206.173/kabuapi/api/MarketInfo/RankingDataList?rankingType={ランキング種別}&Market={市場コード}&Sector={業種コード}&pageNum={ページ番号※省略可(Default=1)}&pageSize={1ページ当たりの表示件数※省略可(Default=20)}
    # tmp = EqJsonData.where(["js_key = 'MarketInfo/RankingDataList' and js_para = ? ",@rkinf.join("|")]).order("js_seq")
    @info_Ranking = GetJsonData(API_SERVER_URL + '/MarketInfo/RankingDataList?rankingType=' + @rkinf[0] + '&Market=' + @rkinf[1] + '&Sector=' + @rkinf[2] + '&pageSize=60')

    # nowIdx = -1
    # tmp.each do |d|
    #   if nowIdx != d["js_seq"] then
    #     @rkdata << {}
    #     nowIdx = d["js_seq"]
    #   end
    #   @rkdata[nowIdx].store(d["js_d_key"],d["js_d_value"])
    # end

    @rkdata = Kaminari.paginate_array(@info_Ranking).page(params[:page]).per(20)

  end

  ###ストラテジランキング
  def stgranking
    @rklist = {"1" => "主要500銘柄（TOPIX500）", "2" => "全銘柄"}
    @sortlist = {"1" => "平均パフォーマンス", "2" => "最大損益", "3" => "最低損益"}
    @rkinf = []
    if params[:r] == nil then
       @rkinf << "1"
       @rkinf << "1"
    else
       @rkinf << params[:r]
       @rkinf << params[:s]
    end

    # ストラテジランキング
    # http://39.110.206.173/kabuapi/api/StrategyRanking?id={※ID}
    #   ※ID ：対象銘柄
    #   主要500銘柄（TOPIX500）：1
    # 　全銘柄：2
    @rkdata = GetJsonData(API_SERVER_URL + '/StrategyRanking?id=' + @rkinf[0])


    # @rkdata = []
    # tmp = EqJsonData.where(["js_key = 'StrategyRanking' and js_para = ? ",@rkinf[0]]).order("js_seq")
    # nowIdx = -1
    # tmp.each do |d|
    #   if nowIdx != d["js_seq"] then
    #     @rkdata << {}
    #     nowIdx = d["js_seq"]
    #   end
    #   @rkdata[nowIdx].store(d["js_d_key"],d["js_d_value"])
    # end
    if @rkinf[1] == "2" then
      @rkdata.sort! do |a, b|
        ret = -1 * (a["best_return"].to_f - b["best_return"].to_f)
      end
    end
    if @rkinf[1] == "3" then
      @rkdata.sort! do |a, b|
        ret = (a["worst_return"].to_f - b["worst_return"].to_f)
      end
    end
  end

  ###銘柄別ストラテジランキング
  def issueranking
    @rklist = {"1" => "パフォーマンスランキング","2" => "勝率ランキング","3" => "取引回数ランキング","4" => "取引保有日数ランキング","5" => "シャープレシオランキング","6" => "プロフィットファクターランキング","7" => "1取引あたり期待値ランキング","8" => "最大ドローダウンランキング"}
    @rkinf = []
    if params[:r] == nil then
       @rkinf << "1"
    else
       @rkinf << params[:r]
    end

    @rkdata = []

    # tmp = EqJsonData.where(["js_key = 'StrategyByTickerRanking/DataList' and js_para = ? ",@rkinf[0]]).order("js_seq")
    # nowIdx = -1
    # tmp.each do |d|
    #   if nowIdx != d["js_seq"] then
    #     @rkdata << {}
    #     nowIdx = d["js_seq"]
    #   end
    #   @rkdata[nowIdx].store(d["js_d_key"],d["js_d_value"])
    # end

    # WebAPIを使う
    # 銘柄別ストラテジーランキング
    # http://service.valueoptima.com/kabuapi/api/StrategyByTickerRanking/DataList?id={※ID}&pageNum={ページ番号}&pageSize={1ページ当たりの表示件数}&accountID={アカウントID※省略可}
    info_Ranking = GetJsonData(API_SERVER_URL + '/StrategyByTickerRanking/DataList?id=' + @rkinf[0] + '&pageNum=1&pageSize=20')

    @rkdata = Kaminari.paginate_array(info_Ranking).page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.js if request.xhr?
    end

  end

  ###投資戦略室
  def recranking
    @rklist = {"1" => "主要500銘柄（TOPIX500）", "2" => "全銘柄"}
    @sortlist = {"1" => "ハイパフォーマンス型", "2" => "ローリスク型", "3" => "長期投資型", "4" => "中期投資型", "5" => "短期投資型"}
    desc = ["とにかく、高パフォーマンスを追及する人におすすめです。何を買ったらいいか分からない人、『今日の株』まかせで、ロボット投資がしたい人。","パフォーマンスよりも、少ないリスクで安定的な投資をしたい人におすすめです。少ない金額で、大きな収益をあげたい人。","長期間にわたってのんびりと投資をしたい人におすすめします。長期投資型では、値動きの少ない銘柄を売買するので、頻繁な取引が面倒な人にうってつけです。※過去に仮想取引の決済までの平均期間が1ヶ月以上のものをピックアップしています。","長期間では長すぎるが、短期間では短すぎる人におすすめします。中期投資型では、適度に値動きのある銘柄を売買します。※過去に仮想取引の決済までの平均期間が1週間以上1ヶ月未満のものをピックアップしています。","短期間でパフォーマンスを求めたい人におすすめします。短期投資型では、値動きが大きく、頻繁に取引が発生する可能性の高い銘柄をおすすめします。※過去に仮想取引の決済までの平均期間が1週間以内のものをピックアップしています。"]
    @rkinf = []
    if params[:r] == nil then
       @rkinf << "1"
       @rkinf << "1"
    else
       @rkinf << params[:r]
       @rkinf << params[:s]
    end
    @rkdesc = desc[@rkinf[1].to_i - 1]

    @rkdata = []
    # tmp = EqJsonData.where(["js_key = 'Recommend/DataList' and js_para = ? ",@rkinf.join("|")]).order("js_seq")
    # nowIdx = -1
    # tmp.each do |d|
    #   if nowIdx != d["js_seq"] then
    #     @rkdata << {}
    #     nowIdx = d["js_seq"]
    #   end
    #   @rkdata[nowIdx].store(d["js_d_key"],d["js_d_value"])
    # end


    ###------------ WebAPI 使用する
    #http://service.valueoptima.com/kabuapi/api/Recommend/DataCount?id={※ID}&rankType={※ランキングタイプ}}&accountID={アカウントID※省略可}

    # rkdata_count = GetJsonData(API_SERVER_URL + '/Recommend/DataCount?id=' + @rkinf[0] + '&rankType=' + @rkinf[1])

    # ■おすすめ銘柄データ取得
    # http://39.110.206.173/kabuapi/api/Recommend/DataList?id={※ID}&rankType={※ランキングタイプ}&pageNum={ページ番号}&pageSize={1ページ当たりの表示件数}&accountID={アカウントID※省略可}

    #   ※ID ：対象銘柄
    # 　主要500銘柄（TOPIX500）：1
    # 　全銘柄：2
    # ※ランキングタイプ
    # 　ハイパフォーマンス型： 1
    # 　ローリスク型： 2
    # 　長期投資型： 3
    # 　中期投資型： 4
    # 　短期投資型： 5
    # @rkdata = GetJsonData(API_SERVER_URL + '/Recommend/DataList?id=' + @rkinf[0] + '&rankType=' + @rkinf[1] + '&pageNum=1&pageSize=' + (rkdata_count[0]['count']-1).to_s)
    @rkdata = GetJsonData(API_SERVER_URL + '/Recommend/DataList?id=' + @rkinf[0] + '&rankType=' + @rkinf[1] + '&pageNum=1&pageSize=20')

    @rkdata = Kaminari.paginate_array(@rkdata).page(params[:page]).per(20)

  end

  def check_stock_data(stock_data)
    if !stock_data["mkt_date"].present?
      return false
    end

    if !stock_data["open_price"].present?
      return false
    end
    # if !float_string?(stock_data["open_price"].to_s)
    #   return false
    # end

    if !stock_data["high_price"].present?
      return false
    end
    # if !float_string?(stock_data["high_price"].to_s)
    #   return false
    # end

    if !stock_data["low_price"].present?
      return false
    end
    # if !float_string?(stock_data["low_price"].to_s)
    #   return false
    # end

    if !stock_data["close_price"].present?
      return false
    end
    # if !float_string?(stock_data["close_price"].to_s)
    #   return false
    # end
    true
  end

  def stock_graph(data)

    color = '#FFCC33'
    stock_value = []
    stock_volume = []
    # wk_split_rate = EqtySplitRate.where(mkt_ticker_code: wk_code).order_by(['effective_date', :desc])
    # wk_rate_data = {}
    # add_rate = 1
    # wk_split_rate.each do |wk_rate|
    #   add_rate *= wk_rate.ratio_from / wk_rate.ratio_to
    #   wk_rate_data[wk_rate.effective_date.to_s] = add_rate
    # end
    data.each_with_index do |stock_data,idx|
      if check_stock_data(stock_data)
      #  wk_split_rate_set = wk_split_rate.where(:effective_date.gte => stock_data.mkt_date)
        add_rate = 1
        # wk_rate_data.each do |key , val|
        #   if key >= stock_data.mkt_date
        #     add_rate = val
        #   end
        # end
        stock_volume.push([DateTime.parse(stock_data["mkt_date"]).to_i * 1000, (stock_data["volume"]).to_f])
        stock_value.push([DateTime.parse(stock_data["mkt_date"]).to_i * 1000, (stock_data["open_price"] * add_rate).to_f, (stock_data["high_price"] * add_rate).to_f, (stock_data["low_price"] * add_rate).to_f, (stock_data["close_price"] * add_rate).to_f])
      end
    end
    groupingUnits = [[
                'week',                         # unit name
                [1]                             # allowed multiples
            ], [
                'month',
                [1, 2, 3, 4, 6]
            ]]
    LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({
                  :marginLeft => 15,
                  :marginRight => 30,
                  :backgroundColor => '#000000',
                  :borderColor => '#FFFFFF',
                  :height => 600,
                  :borderWidth => 1

              })
      f.rangeSelector({
                # デフォルトで表示するチャートの期間を指定
                selected: 1
            })
      f.title({
                  text: "株価推移グラフ"
            })
      f.yAxis([{
                  labels: {
                    align: 'right',
                    x: -3
                  },
                  title: {
                    text: 'OHLC'
                  },
                  height: '65%',
                  lineWidth: 2
              },{
                  labels: {
                    align: 'right',
                    x: -3
                  },
                  title: {
                    text: 'Volume'
                  },
                  top: '70%',
                  height: '30%',
                  offset: 0,
                  lineWidth: 2
              }])
      f.series({
                   name: '株価',
                   type: 'candlestick',
                   data: stock_value,
                   dataGrouping: {
                       units: groupingUnits
                   }
               })
      f.series({
                   name: '取引数',
                   type: 'column',
                   data: stock_volume,
                   dataGrouping: {
                       units: groupingUnits
                   },
                   yAxis: 1
               })
    end
  end

  def twiinfo
    cd = params[:c]
    tp = params[:t]
    tmp = EquitySns.where(["sec_code = ? and sns_type = 1 and sns_no = ?",cd,tp])
    tmp.each do |d|
      @twiurl = tmp.first[:sns_url]
      break
    end
    @twidata = TwitterData.where("sec_code = ? and sns_no = ? ",cd,tp).order("sns_date desc").page(params[:page])
  end

  # ストラテジグラフ
  def strategy_page_graph(datas)
    # チャートのデータを作成する
    stock_datas = []
    strategy_datas1 = []
    strategy_datas2 = []

    datas.each do |data|
      date = DateTime.parse(data['mkt_date']).to_i * 1000
      realized_data = data['realized_pl'].to_i
      value_data = data['value_pl'].to_i

      stock_datas << [date, data['open_price'], data['high_price'].to_f, data['low_price'].to_f, data['close_price'].to_f]
      strategy_datas1 << [date, realized_data]
      strategy_datas2 << [date, value_data]
    end


    # 株価チャートに売り買いのタグを付ける
    open_datas_set = []
    close_datas_set = []

    @info_simTradeList.each.with_index(1) do |flag_data, index|
      open_data = {}
      close_data = {}

      open_day = DateTime.parse(flag_data['open_day']).to_i * 1000
      close_day = DateTime.parse(flag_data['close_day']).to_i * 1000 unless flag_data['close_day'] == nil
      text_open_day = flag_data['open_day'].match(/\A(\d{4}-\d{2}-\d{2})/)[1] unless flag_data['open_day'].blank?
      text_close_day = flag_data['close_day'].match(/\A(\d{4}-\d{2}-\d{2})/)[1] unless flag_data['close_day'].blank?
      trade_price = flag_data['trade_price'].to_i
      close_price = flag_data['close_price'].to_i
      flag = flag_data['trade_sign']
      realized_price = flag_data['accume_realized']

      if flag == 1
        open_data[:x] = open_day
        open_data[:text] = "#{text_open_day} 買 #{trade_price}"
        open_data[:title] = index
        close_data[:x] = close_day
        close_data[:text] = "#{text_close_day} 売 #{close_price} 決済:  #{realized_price}"
        close_data[:title] = index
      else
        open_data[:x] = open_day
        open_data[:text] = "#{text_open_day} 売 #{trade_price}"
        open_data[:title] = index
        close_data[:x] = close_day
        close_data[:text] = "#{text_close_day} 買"
        close_data[:title] = index
      end

      open_datas_set << open_data
      close_datas_set << close_data
    end

    groupingUnits = [[
                'week',                         # unit name
                [1]                             # allowed multiples
            ], [
                'month',
                [1, 2, 3, 4, 6]
            ]]

    @stock_graph = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart({
        :backgroundColor => '#1c1c1c',
        :borderColor => '#000000',
        :borderWidth => 1,
        height: 500,
      })

      f.rangeSelector({
        selected: 5,
        # inputEnabled: false
      })

      f.title({
        text: "株式チャート",
        style: {
          fontFamily: 'Verdana, sans-serif',
          color: '#fff'
        }
      })
      f.yAxis([{
        labels: {
          align: 'right',
          x: -3
        },
        title: { text: '株価' },
        height: '47%',
        lineWidth: 2
      },{
        labels: {
          align: 'right',
          x: -3
        },
        title: { text: '累積損益、評価損益' },
        top: '50%',
        height: '47%',
        offset: 0,
        lineWidth: 2
      }])

      f.series({
        name: '株価',
        type: 'candlestick',
        data: stock_datas,
        id: 'stock',
        dataGrouping: { units: groupingUnits },
      })

      f.series({
        type: 'flags',
        data: open_datas_set,
        onSeries: 'stock',
        shape: 'circlepin'
      })

      f.series({
        type: 'flags',
        data: close_datas_set,
        onSeries: 'stock',
        shape: 'squarepin',
        color: '#00b400'
      })

      f.series({
        name: '累積損失',
        type: 'area',
        lineWidth: 2,
        color: '#00ffff',
        data: strategy_datas1,
        yAxis: 1,
        dataGrouping: {
            units: groupingUnits
        },
      })

      f.series({
        name: '評価損失',
        type: 'line',
        lineWidth: 4,
        color: '#0000ff',
        data: strategy_datas2,
        yAxis: 1,
        dataGrouping: {
            units: groupingUnits
        },
      })
    end
  end

  def issueinfo
    cd = params[:t]
    # tmp = EquityIssue.where(["eqty_ticker = ?",cd])
    # @info = tmp.first

    #銘柄情報取得
    @wk_stock =get_wk_stock(params[:t])

    @secList = {}
    tmp = EqJsonData.where(["js_key = 'MarketInfo/SectorList.json'"]).order("js_seq")
    lastIndex = -1
    nowKey = ""
    nowValue = ""
    tmp.each do |d|
      if lastIndex != d["js_seq"] then
        if d["js_d_key"] == "instance_no" then
          nowKey = d["js_d_value"]
        elsif d["js_d_key"] == "text_01" then
          nowValue = d["js_d_value"]
        end
        if nowKey != "" && nowValue != "" then
          @secList[nowKey] = nowValue
          nowKey = ""
          nowValue = ""
          lastIndex = d["js_seq"]
        end
      end
    end
    tmp = EquitySns.where("sec_code = ?",cd)
    @twi = {}
    tmp.each do |d|
      if d["sns_type"] == 1 && d["sns_no"] == 0 then
        @twi["CEO"] = d["sns_url"]
      elsif d["sns_type"] == 1 && d["sns_no"] == 1 then
        @twi["ISSUE"] = d["sns_url"]
      end
    end
    @articles = Kaminari.paginate_array(get_csv_data[0, 2]).page(params[:page]).per(10)
    stock_price
    strategylist
    @wk_stock_price = Kaminari.paginate_array(@wk_stock_price.reverse).page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.js if request.xhr?
    end

    # tmp2 = SecuritiesPrice.where(["sec_code = ? and pdate >= DATE_ADD(now(), INTERVAL -1 YEAR)",cd]).order("pdate")
    # stock_volume = []
    # stock_value = []
    # tmp2.each do |d|
    #   stock_volume.push([DateTime.parse(d["pdate"].to_s).to_i*1000,d["volume"].to_f])
    #   stock_value.push([DateTime.parse(d["pdate"].to_s).to_i*1000, d["open"].to_f, d["high"].to_f, d["low"].to_f, d["close"].to_f])
    #   # byebug
    # end
    # color = '#FFCC33'
    # groupingUnits = [[
    #             'week',                         # unit name
    #             [1]                             # allowed multiples
    #         ], [
    #             'month',
    #             [1, 2, 3, 4, 6]
    #         ]]

    # @wk_stock_data=LazyHighCharts::HighChart.new('graph') do |f|
    #   f.chart({
    #               :marginLeft => 15,
    #               :marginRight => 30,
    #               :backgroundColor => '#000000',
    #               :borderColor => '#FFFFFF',
    #               :height => 600,
    #               :borderWidth => 1

    #           })
    #   f.rangeSelector({
    #             # デフォルトで表示するチャートの期間を指定
    #             selected: 1
    #         })
    #   f.title({
    #           text: "株価推移グラフ"
    #         })
    #   f.yAxis([
    #           {
    #               labels: {
    #                 align: 'right',
    #                 x: -3
    #               },
    #               title: {
    #                 text: 'OHLC'
    #               },
    #               height: '65%',
    #               lineWidth: 2
    #           },
    #           {
    #               labels: {
    #                 align: 'right',
    #                 x: -3
    #               },
    #               title: {
    #                 text: 'Volume'
    #               },
    #               top: '70%',
    #               height: '30%',
    #               offset: 0,
    #               lineWidth: 2
    #           }])
    #   f.series({
    #                name: '株価',
    #                type: 'candlestick',
    #                data: stock_value,
    #                dataGrouping: {
    #                    units: groupingUnits
    #                },
    #                yAxis: 0
    #            })
    #   f.series({
    #                name: '取引数',
    #                type: 'column',
    #                data: stock_volume,
    #                dataGrouping: {
    #                    units: groupingUnits
    #                },
    #                yAxis: 1
    #            })
    # end

    # cd = params[:c]
    # url = "http://39.110.206.173/kabuapi/api/TickerInfo/SecurityInfo?ticker="
    # url << cd
    # uri = URI.parse(url)
    # json = Net::HTTP.get(uri)
    # datas = JSON.parse(json)
    # if datas == nil || datas.length == 0 then
    #   return
    # end
    # issue = datas.first
    # url = "http://39.110.206.173/kabuapi/api/TickerInfo/CompanyInfo?ticker="
    # url << cd
    # uri = URI.parse(url)
    # json = Net::HTTP.get(uri)
    # datas = JSON.parse(json)
    # if datas == nil || datas.length == 0 then
    #   return
    # end
    # comp = datas.first
    # @info = issue.merge(comp)

    # tmp = SecuritiesPrice.where(["sec_code = ? and pdate >= DATE_ADD(now(), INTERVAL -1 YEAR)",cd]).order("pdate")
    # pd = []
    # pv = []
    # tmp.each do |d|
    #   pv << [DateTime.parse(d["pdate"].to_s).to_i * 1000,d["volume"]]
    #   pd <<[DateTime.parse(d["pdate"].to_s).to_i * 1000, d["open"].to_f, d["high"].to_f, d["low"].to_f, d["close"].to_f]
    #   # pv.push( [DateTime.parse(d["pdate"].to_s),d["volume"]])
    #   # pd.push([DateTime.parse(d["pdate"].to_s), d["open"].to_f, d["high"].to_f, d["low"].to_f, d["close"].to_f])
    # end
    # @graph = stock_graph(pd,pv)

    # category = [1,3,5,7]
    # current_quantity = [1000,5000,3000,8000]

    # @graph = LazyHighCharts::HighChart.new('graph') do |f|
    #   f.title(text: 'ItemXXXの在庫の推移')
    #   f.xAxis(categories: category)
    #   f.series(name: '在庫数', data: current_quantity)
    # end

    # @chart = LazyHighCharts::HighChart.new('graph') do |f|
    #   f.title({ :text=>"Combination chart"})
    #   f.options[:xAxis][:categories] = ['Apples', 'Oranges', 'Pears', 'Bananas', 'Plums']
    #   f.labels(:items=>[:html=>"Total fruit consumption", :style=>{:left=>"40px", :top=>"8px", :color=>"black"} ])
    #   f.series(:type=> 'column',:name=> 'Jane',:data=> [3, 2, 1, 3, 4])
    #   f.series(:type=> 'column',:name=> 'John',:data=> [2, 3, 5, 7, 6])
    #   f.series(:type=> 'column', :name=> 'Joe',:data=> [4, 3, 3, 9, 0])
    #   f.series(:type=> 'spline',:name=> 'Average', :data=> [3, 2.67, 3, 6.33, 3.33])
    #   f.series(:type=> 'pie',:name=> 'Total consumption',
    #     :data=> [
    #       {:name=> 'Jane', :y=> 13, :color=> 'red'},
    #       {:name=> 'John', :y=> 23,:color=> 'green'},
    #       {:name=> 'Joe', :y=> 19,:color=> 'blue'}
    #     ],
    #     :center=> [100, 80], :size=> 100, :showInLegend=> false)
    #   end

    #   @chart2 = LazyHighCharts::HighChart.new('graph') do |f|
    #     f.title(:text => "Population vs GDP For 5 Big Countries [2009]")
    #     f.xAxis(:categories => ["United States", "Japan", "China", "Germany", "France"])
    #     f.series(:name => "GDP in Billions", :yAxis => 0, :data => [14119, 5068, 4985, 3339, 2656])
    #     f.series(:name => "Population in Millions", :yAxis => 1, :data => [310, 127, 1340, 81, 65])

    #     f.yAxis [
    #       {:title => {:text => "GDP in Billions", :margin => 70} },
    #       {:title => {:text => "Population in Millions"}, :opposite => true},
    #     ]

    #     f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
    #     f.chart({:defaultSeriesType=>"column"})
    #   end

    #   @chart3 = LazyHighCharts::HighChart.new('pie') do |f|
    #         f.chart({:defaultSeriesType=>"pie" , :margin=> [50, 200, 60, 170]} )
    #         series = {
    #                  :type=> 'pie',
    #                  :name=> 'Browser share',
    #                  :data=> [
    #                     ['Firefox',   45.0],
    #                     ['IE',       26.8],
    #                     {
    #                        :name=> 'Chrome',
    #                        :y=> 12.8,
    #                        :sliced=> true,
    #                        :selected=> true
    #                     },
    #                     ['Safari',    8.5],
    #                     ['Opera',     6.2],
    #                     ['Others',   0.7]
    #                  ]
    #         }
    #         f.series(series)
    #         f.options[:title][:text] = "THA PIE"
    #         f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'})
    #         f.plot_options(:pie=>{
    #           :allowPointSelect=>true,
    #           :cursor=>"pointer" ,
    #           :dataLabels=>{
    #             :enabled=>true,
    #             :color=>"black",
    #             :style=>{
    #               :font=>"13px Trebuchet MS, Verdana, sans-serif"
    #             }
    #           }
    #         })
    #   end

    #   @chart4 = LazyHighCharts::HighChart.new('column') do |f|
    #     f.series(:name=>'John',:data=> [3, 20, 3, 5, 4, 10, 12 ])
    #     f.series(:name=>'Jane',:data=>[1, 3, 4, 3, 3, 5, 4,-46] )
    #     f.title({ :text=>"example test title from controller"})
    #     f.options[:chart][:defaultSeriesType] = "column"
    #     f.plot_options({:column=>{:stacking=>"percent"}})
    #   end
  end

  def get_csv_data
    file_path = File.expand_path('csv/relative_news.csv', Rails.root).to_s
    csv_datas = []
    CSV.foreach(file_path, quote_char: "|") do |row|
      data = {}
      data[:date] = row[0].gsub(/\Ai/, '')
      data[:time] = row[1]
      data[:article_name] = row[2]
      data[:article] = row[4]
      data[:source] = row[7]
      data.each do |key, value|
        data[key] = value.match(/\A['’](.*)'\z/)[1] unless value.match(/\A['’](.*)'\z/) == nil
      end
      csv_datas << data
    end
    csv_datas
  end

  #「株価情報」画面
  def stock_info
    @cd = params[:t]
    @a = 1

    #---銘柄情報取得
    # begin
    #   tmp = EquityIssue.where(["eqty_ticker = ?",@cd])
    #   @wk_stock = tmp.first
    # rescue
    #   return @wk_stock = false
    # end
    @wk_stock =get_wk_stock(@cd)

    #銘柄別ストラテジーリスト（収益平均）
    #http://39.110.206.173/kabuapi/api/StrategyByTicker/StrategyAverageReturn?ticker={4桁銘柄コード}
    @stg_AverageReturn = GetJsonData(API_SERVER_URL + '/StrategyByTicker/StrategyAverageReturn?ticker=' + params[:t])

    #銘柄別ストラテジーリスト
    #http://39.110.206.173/kabuapi/api/StrategyByTicker/StrategyList?ticker={4桁銘柄コード}
    @stg_List = GetJsonData(API_SERVER_URL + '/StrategyByTicker/StrategyList?ticker=' +params[:t])


    # # ○株価ヒストリカルデータ(分割等調整後)
    # # http://39.110.206.173/kabuapi/api/TickerInfo/HistoricalData?ticker={4桁銘柄コード}&ChartTerm={取得月数※}
    # @wk_stock_price = GetJsonData(API_SERVER_URL + '/TickerInfo/HistoricalData?ticker=' + @cd)

    # # @wk_stock_price = MktEqtyPrice.where("$and" => [{fnp_eqty_id: @wk_stock.id}, {market_code:@wk_stock.preferred_market}]).order_by(['mkt_date', :asc])
    # @wk_stock_data = stock_graph(@wk_stock_price)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def stock_price
    @cd = params[:t]

    # ○株価ヒストリカルデータ(分割等調整後)
    # http://39.110.206.173/kabuapi/api/TickerInfo/HistoricalData?ticker={4桁銘柄コード}&ChartTerm={取得月数※}
    @wk_stock_price = GetJsonData(API_SERVER_URL + '/TickerInfo/HistoricalData?ticker=' + @cd)

    #j###########
    @pre_dataj1,@tickerj1,@tickern1 = getPreData( @cd , params[:ratios] )
    #j###########
  
    # @wk_stock_price = MktEqtyPrice.where("$and" => [{fnp_eqty_id: @wk_stock.id}, {market_code:@wk_stock.preferred_market}]).order_by(['mkt_date', :asc])
    @wk_stock_data = stock_graph(@wk_stock_price)

    # respond_to do |format|
    #   format.html
    #   format.js
    # end

  end

  def edit
    cd = params[:t]
   # tmp = EquityIssue.where(["eqty_ticker = ?",cd])
    #@wk_stock = tmp.first
    @wk_stock = get_wk_stock(cd)
    @secList = {}
    tmp = EqJsonData.where(["js_key = 'MarketInfo/SectorList.json'"]).order("js_seq")
    lastIndex = -1
    nowKey = ""
    nowValue = ""
    tmp.each do |d|
      if lastIndex != d["js_seq"] then
        if d["js_d_key"] == "instance_no" then
          nowKey = d["js_d_value"]
        elsif d["js_d_key"] == "text_01" then
          nowValue = d["js_d_value"]
        end
        if nowKey != "" && nowValue != "" then
          @secList[nowKey] = nowValue
          nowKey = ""
          nowValue = ""
          lastIndex = d["js_seq"]
        end
      end
    end
    tmp = EquitySns.where("sec_code = ?",cd)
    @twi = {}
    tmp.each do |d|
      if d["sns_type"] == 1 && d["sns_no"] == 0 then
        @twi["CEO"] = d["sns_url"]
      elsif d["sns_type"] == 1 && d["sns_no"] == 1 then
        @twi["ISSUE"] = d["sns_url"]
      end
    end
    respond_to do |format|
      format.html
      format.js if request.xhr?
    end
  end

  def time_series
    @cd = params[:t]
    begin
      tmp = EquityIssue.where(["eqty_ticker = ?",@cd])
      wk_stock = tmp.first
    rescue
      return wk_stock = false
    end

    wk_array = []
    # ○株価ヒストリカルデータ(分割等調整後)
    # http://39.110.206.173/kabuapi/api/TickerInfo/HistoricalData?ticker={4桁銘柄コード}&ChartTerm={取得月数※}
    wk_stock_price = GetJsonData(API_SERVER_URL + '/TickerInfo/HistoricalData?ticker=' + @cd)

    wk_stock_price.each_with_index do |wk_price,idx|
      set_data = {}

      set_data['mkt_date'] = wk_price['mkt_date']
      set_data['open_price'] = wk_price['open_price']
      set_data['close_price'] = wk_price['close_price']
      set_data['low_price'] = wk_price['low_price']
      set_data['high_price'] = wk_price['high_price']
      set_data['volume'] = wk_price['volume']

      wk_array.push(set_data)
    end

    #降順にする
    wk_array.sort! do |a, b|
      b['mkt_date'] <=> a['mkt_date']
    end
    wk_array
  end

  def bitcoin
    db_price_data = BitcoinPrice.where(ccy_code: "JPY")
    price_data = []
    db_price_data.each do |d|
      price_data << [d['base_time'].to_i * 1000, d['price'].round(0)]
    end

    @bitgra = LazyHighCharts::HighChart.new('graph') do |f|
      # f.title(text: "BitCoin")
      # f.xAxis(categories: pd,tickInterval:1)
      # f.options[:yAxis] = [{ title: { text: '時価' }, opposite: true}]
      # f.series(name: '時価', data: pclose,type: 'spline',yAxis: 0,color: '#BF0B23')
      f.chart({
        marginLeft: 15,
        marginRight: 30,
        backgroundColor: '#1c1c1c',
        borderColor: '#000000',
        height: 450,
        borderWidth: 1
      })

      f.rangeSelector({
        selected: 0,
        inputEnabled: false
      })

      f.title({
        text: "ビットコインチャート",
        style: {
          fontFamily: 'Verdana, sans-serif',
          color: '#fff'
        }
      })

      f.legend({
        enabled: true,
        borderWidth: 2,
        itemStyle: { color: '#fff' },
        itemHoverStyle: { color: '#000' },
        itemHiddenStyle: { color: '#E0E0E3' },
      })

      f.plot_options({
        series: { color: '#ff8282' }
      })

      f.yAxis([{
        labels: {
          aligin: 'right',
          x: -3,
          style: { color: 'silver' },
          formatter: "function() { return this.value.toLocaleString() }".js_code,
        },
        height: '90%',
       }])

      f.xAxis({
        labels: {
          style: { color: 'silver' }
        }
      })

      f.series({
        name: '価格 (\)',
        type: 'line',
        lineWidth: 2,
        color: '#ff8282',
        data: price_data
      })
    end
  end

  def issuelist
    sql = []
    @pars = {}
    if  params[:tick_code].present? then
      sql << "(eqty_ticker = '" + params[:tick_code] + "')"
    end
    if  params[:issue_name].present? then
      sql << "(eqty_name like '%" + params[:issue_name] + "%' or eqty_name_kana like  '%" + params[:issue_name] + "%')"
    end
    if sql.length > 0
      @equties = EquityIssue.where(sql.join(" and ")).page(params[:page])
    else
      @equties = EquityIssue.all.page(params[:page])
    end
  end

  #銘柄別ストラテジ
  def tickerdetail
    #銘柄情報取得
    @wk_stock =get_wk_stock(params[:t])
    #ストラテジの運用成績
    @info_performance = GetJsonData(API_SERVER_URL + '/StrategyByTicker/Performance?ticker=' + params[:t] + '&strategyId=' + params[:s])

    #損益シミュレーション
    @info_simTradeList = GetJsonData(API_SERVER_URL + '/StrategyByTicker/SimTradeList?ticker=' + params[:t] + '&strategyId=' + params[:s])

    data_list = GetJsonData(API_SERVER_URL + '/StrategyByTicker/PLList?ticker=' + params[:t] + '&strategyId=' + params[:s])
    strategy_page_graph(data_list)
  end

  #ストラテジ結果
  def strategyresult
    #パラメータ取得
    @mkt_ticker_code = params[:t]
    @mkt_ticker_name = params[:n]
    @strategy_id = params[:s]

    r=params[:r]

    # #ストラテジ内銘柄ランキング(件数取得)
    # #http://39.110.206.173/kabuapi/api/Strategy/DataCount/IsTopix500?strategyId={ストラテジーID}&AccountID={アカウントID※省略可}
    # #http://39.110.206.173/kabuapi/api/Strategy/DataCount/All?strategyId={ストラテジーID}&AccountID={アカウントID※省略可}
    # @count = GetJsonData(API_SERVER_URL + '/Strategy/DataCount/IsTopix500?strategyId=' + @strategy_id)

    #ストラテジの運用成績/ストラテジの概要
    #http://39.110.206.173/kabuapi/api/Strategy/Performance/All?strategyId={ストラテジーID}&AccountID={アカウントID※省略可}
    #http://39.110.206.173/kabuapi/api/Strategy/Performance/IsTopix500?strategyId={ストラテジーID}&AccountID={アカウントID※省略可}
    @info_Result =
      if r=='1'
        GetJsonData(API_SERVER_URL + '/Strategy/Performance/All?strategyId=' + @strategy_id)
      else
        GetJsonData(API_SERVER_URL + '/Strategy/Performance/IsTopix500?strategyId=' + @strategy_id)
      end
    #ストラテジ内銘柄ランキング
    #http://39.110.206.173/kabuapi/api/Strategy/Ranking/All?pageNum={ページ番号}&pageSize={1ページ当たりの表示件数}&strategyId={ストラテジーID}&AccountID={アカウントID※省略可}
    #http://39.110.206.173/kabuapi/api/Strategy/Ranking/IsTopix500?pageNum={ページ番号}&pageSize={1ページ当たりの表示件数}&strategyId={ストラテジーID}&AccountID={アカウントID※省略可}
    @info_Ranking =
      if r=='1'
        GetJsonData(API_SERVER_URL + '/Strategy/Ranking/All?pageNum= 1' + '&pageSize=' + '10000' + '&strategyId=' + @strategy_id)
      else
        GetJsonData(API_SERVER_URL + '/Strategy/Ranking/IsTopix500?pageNum= 1' + '&pageSize=' + '10000' + '&strategyId=' + @strategy_id)
      end
    @rkdata = Kaminari.paginate_array(@info_Ranking).page(params[:page]).per(20)

  end

  #ストラテジ結果
  def strategylist
    #銘柄別ストラテジーリスト（収益平均）
    #http://39.110.206.173/kabuapi/api/StrategyByTicker/StrategyAverageReturn?ticker={4桁銘柄コード}
    @stg_AverageReturn = GetJsonData(API_SERVER_URL + '/StrategyByTicker/StrategyAverageReturn?ticker=' + params[:t])

    #銘柄別ストラテジーリスト
    #http://39.110.206.173/kabuapi/api/StrategyByTicker/StrategyList?ticker={4桁銘柄コード}
    @stg_List = GetJsonData(API_SERVER_URL + '/StrategyByTicker/StrategyList?ticker=' +params[:t])

#    respond_to do |format|
#      format.html
#      format.js if request.xhr?
#    end
  end


  def getPreData(ticker,ratios)
    
    strDataSql = " select * from  securities_predict_lists where ticker= '" + ticker.to_s +  "' order by mk_d desc ,mk_p_d asc,ticker LIMIT 10; " 
    
    #add search ,exception
    begin
      trends = ActiveRecord::Base.connection.select_all(strDataSql)
      pTrend2 = getBasicData(ticker)   
     
    rescue
      trends = []
      pTrend2 = []  
      @tickern   = ' N/A'
      
    end 
   
    @basic_dataj= pTrend2.clone
 
 
    pTrend3=[]
    trends.each do |d|
        pTrend1 = [] 
       
        pTrend1 << (d['mk_p_d']).strftime("%Y/%m/%d") 
        pTrend1 << d['price']
     
        #pTrend2 << pTrend1
        pTrend3 << pTrend1
    end

    @tickerj   = ticker
    #@pre_dataj = pTrend2
    @pre_dataj = pTrend3

    strDataSql1 = " select eqty_name from  equity_issue where eqty_ticker= '" + ticker.to_s +  "' LIMIT 1; " 
    
    #add search ,exception
    begin
      trends1 = ActiveRecord::Base.connection.select_all(strDataSql1)
      @tickern = trends1[0]['eqty_name']
    rescue
      trends1 = []
      @tickern   = 'N/A'
      
    end 
       
    ############################test radar chart


    #define the interface message structure
    #in
    # NAME            , Location,  description 
    # ticker,           params 1 , the company ticker
    # columns,        , params 2 , the indicators name
     
    
    
    
    
    #out
    # NAME            , Location,  description 
    # return value,    0,       ,  ticker
    # file name,       1,          html file name 

    @testj  = ""
    cols = ratios

    #"," is the split symbol.
    #@testj  = exec("python c:/xj/radar.py "+(ticker.to_s)+" "+(cols) )
    ######1 type#######
    

    # sys.argv[1] = ticker.to_s
    # sys.argv[2] = cols
    #@testj  = `python c:/SimuTest/app/controllers/py/radar.py`
    # @testj  = `python c:/SimuTest/app/controllers/py/call_Py.py ` (ticker.to_s) cols
    #@testj  = `python c:/SimuTest/app/controllers/py/call_Py.py ticker.to_s cols`
    #####2 type#######
    
    #@testj  = exec('python c:/SimuTest/app/controllers/py/call_Py.py '+(ticker.to_s)+' '+cols)
    
    ##3 type
    system 'python', *["c:/SimuTest/app/controllers/py/call_Py.py", ticker.to_s,cols]
    
    ########################
         #system 'python C:/xj/radar.py', ticker.to_s,cols
    #sys.argv = ['c:/xj/radar.py' , ticker.to_s, cols]
    #--system 'python c:/xj/radar.py', ticker.to_s, cols
    #@testj  = exec("python c:/xj/radar.py, ticker.to_s,cols")
            #@testj  =  exec('python', *["c:/xj/radar.py", ticker.to_s,cols])
             #testj  = exec("python c:/xj/radar.py,$(ticker.to_s),$cols")
             #testj  = exec("python c:/xj/radar.py" ,$(ticker.to_s),$cols)
             #testj  = exec("python c:/xj/radar.py" ,g)
    #testj  = exec("python c:/xj/radar.py" ,{(ticker.to_s), cols })
    #testj  = exec("python c:/xj/radar.py" ,{(ticker.to_s)  cols })
    # testj  = exec("python c:/xj/radar.py" ,(cols))
     
             #@testj  = exec("python c:/xj/radar.py,$(ticker.to_s),$cols")   #    @testj  = exec("python c:/xj/radar.py ticker.to_s, cols")       @testj  = exec("python c:/xj/radar.py g")
    #@testj  = `python c:/xj/radar.py`, ticker.to_s,cols
    #system 'python', *["c:/xj/radar.py", ticker.to_s,cols]
    #system 'python', *["c:/xj/radar.py", params1, params2]

      # 0 : {name:'ROE',id:0},
      # 1 : {name:'ROA',id:0},
      # 2 : {name:'R_GP_NS121',id:0},
      # 3 : {name:'R_OP_NS122',id:0},
      # 4 : {name:'R_OP_NS123',id:0},
      # 5 : {name:'R_RP_NS124',id:0},
      # 6 : {name:'Current_R131',id:0},
      # 7 : {name:'Acid_test_R132',id:0},
      # 8 : {name:'R_owner_equity133',id:0},
      # 9 : {name:'Fixed_R134',id:0},
      # 10 : {name:'R_fixAsset_Lgterm135',id:0},
      # 11 : {name:'Ttl_asset_tnOver141',id:0},
      # 12 : {name:'Rcv_tnOver142',id:0},
      # 13 : {name:'Invent_tnOver143',id:0},
      # 14 : {name:'Ttl_pay_tnOver_Period144',id:0},
      # 15 : {name:'R_rd_exp_sale154',id:0},
      # 16 : {name:'Interest_cov_R161',id:0},
      # 17 : {name:'Sale_C_TnOver_Prd162',id:0}

#       
    return @pre_dataj,@tickerj,@tickern, @testj
    
  end
  

 
 # Get basic stock data, that means fetch one stock standard data from database as the SQL exec. It provide the  data to the echart k-line
  def getBasicData(ticker)
    # order for the web page:  date open close lowest highest volume close
    #strDataSql = " (select * from securities_price where sec_code = " + ticker.to_s +  " order by id LIMIT 100) ; " 
    strDataSql = " (select * from securities_price where sec_code = '" + ticker.to_s +  "' order by pdate desc ,sec_code LIMIT 100) order by pdate; "
    
    trends = ActiveRecord::Base.connection.select_all(strDataSql)
    iii=0
    pTrend = []

    highcls =0
    lowcls = 0
    trends.each do |d|
       pTrend1 = [] 
       pTrend1 << (d['pdate']).strftime("%Y/%m/%d")  
       pTrend1 << d['open']
       pTrend1 << d['close']
       pTrend1 << d['low']
       pTrend1 << d['high']
       pTrend1 << d['volume']
     
         
       if highcls < (d['high'])
          highcls = (d['high']).clone
       end
       if lowcls ==0
          lowcls=(d['low']).clone
       end
       if  (d['low']) <lowcls
          lowcls = (d['low']).clone
       end

     
       iii = iii+1
       
       if (100==iii)
          @ylosej= (d['close']).clone
          @yclsh = highcls #highcls.to_f +( 10/(highcls).to_f )
          @yclsl= lowcls #lowcls.to_f-( 10/(lowcls).to_f )
  
       end 
       
       pTrend << pTrend1 
       
   
    end
  
    return pTrend
    
  end
 
 #
 #type 1  ,keep it for implement if need .example as below .
 #@pre_dataj,@tickerj = getPreData(@prediction_top10_u[0]["market_ticker_code"])
 #type 2,for implement future
 #@pre_dataj,@tickerj = getPreData(1301)




  
  ##############
    def prediction_ranking

    @rklist = {"1" => "値上がり率ランキング", "2" => "値下り率ランキング"}
#    @rkdate = {'1' => '1日後', '2' => '2日後', '3' => '3日後', '4' => '4日後', '5' => '5日後',
#               '6' => '6日後', '7' => '7日後', '8' => '8日後', '9' => '9日後', '10' => '10日後'}
    @rkdate = {'1' => '1日目',  '5' => '5日目', '10' => '10日後'}
    @mklist = []
    @seclist = []
    tmp = EqJsonData.where(["js_key = 'MarketInfo/MarketList.json'"]).order("js_seq")
    nowIdx = -1
    tmp.each do |d|
      if nowIdx != d["js_seq"] then
        @mklist << {}
        nowIdx = d["js_seq"]
      end
      @mklist[nowIdx].store(d["js_d_key"],d["js_d_value"])

    end
    tmp = EqJsonData.where(["js_key = 'MarketInfo/SectorList.json'"]).order("js_seq")
    nowIdx = -1
    tmp.each do |d|

      if nowIdx != d["js_seq"] then
        @seclist << {}
        nowIdx = d["js_seq"]
      end
      @seclist[nowIdx].store(d["js_d_key"],d["js_d_value"])
    end

    @rkinf = []
    if params[:r] == nil then
       @rkinf << "1"
       @rkinf << @mklist[0]["instance_no"]
       @rkinf << @seclist[0]["instance_no"]
       @rkinf << '1'
    else
       @rkinf << params[:r]
       @rkinf << params[:m]
       @rkinf << params[:s]
       @rkinf << params[:d]
    end

    if params[:d] == nil then
      params[:d] = "1"
    end


    url = API_SERVER_URL + '/AiMarketinfo/RankingDataList?days=' +
          @rkinf[3] + '&rankingType=' + @rkinf[0] + '&Market=' + @rkinf[1] + '&Sector=' + @rkinf[2] + '&pageSize=60'
    # url = 'http://192.168.1.100/AI_kabuapi/api/AiMarketinfo/RankingDataList?days=' +
    #         @rkinf[3] + '&rankingType=' + @rkinf[0] + '&Market=' + @rkinf[1] + '&Sector=' + @rkinf[2] + '&pageSize=60'
    #
    @info_Ranking = GetJsonData(url)
    print url
    if @info_Ranking.is_a?(Array)
      @rkdata = Kaminari.paginate_array(@info_Ranking).page(params[:page]).per(20)
    end


    #的中率取得
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictHitInfo'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictHitInfo'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictHitInfo'
    #@prediction_hit = GetJsonData(url)
    @prediction_hit = getPredictHit

    #売買予想比率
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictBuySellInfo'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictBuySellInfo'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictBuySellInfo'
    @prediction_buysellinfo = [] 
    @prediction_buysellinfo << getTrendData(1)
    @prediction_buysellinfo << getTrendData(5)
    @prediction_buysellinfo << getTrendData(10)
    
    #トレンドシグナル分布
    strDataSql = " select 1 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = 1 and p_updown > 0  union  select 0 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = 1 and p_updown = 0 union select -1 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = 1 and p_updown < 0"
    trends = ActiveRecord::Base.connection.select_all(strDataSql)
    @predictTrend = @prediction_buysellinfo[0] 

    #TOP10取得 買い
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'u'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'u'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'u'
    #@prediction_top10_u = GetJsonData(url)


    if params[:d].present?  and  (params[:d].to_i >0) then
      days = params[:d]

    else
      days = 1
    end

    #for new rank requirement
    
    rankd = 'topix'
    if params[:rankd].present? then
       rankd = params[:rankd]
    end

    #end of add





    @prediction_top10_u = getPredictData(days,rankd," desc ")


    #TOP10取得 売り
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'd'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'd'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'd'
    @prediction_top10_d = getPredictData(days,rankd," ")

    ##add search 
    if params[:tick_code].present? then
       
    
       
      @pre_dataj,@tickerj,@tickern = getPreData( params[:tick_code],params[:ratios] )
      
      if @pre_dataj.length < 2 then
        @pre_dataj,@tickerj,@tickern = getPreData(@prediction_top10_u[0]["market_ticker_code"], params[:ratios] )
        @nodataj=1
        @nodatan = params[:tick_code]
      else
        @nodataj=0
      end
      
    else
      @nodataj=0
      @pre_dataj,@tickerj,@tickern = getPreData(@prediction_top10_u[0]["market_ticker_code"] , params[:ratios])
      
    end
    
    
    

    #TOP10取得 買い グラフ
    if params[:d] == "1" then
        top1_return_u = BigDecimal(((@prediction_top10_u[0]["close_price_1day"] - @prediction_top10_u[0]["close_price_org"])/@prediction_top10_u[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_u = BigDecimal(((@prediction_top10_u[1]["close_price_1day"] - @prediction_top10_u[1]["close_price_org"])/@prediction_top10_u[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_u = BigDecimal(((@prediction_top10_u[2]["close_price_1day"] - @prediction_top10_u[2]["close_price_org"])/@prediction_top10_u[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_u = BigDecimal(((@prediction_top10_u[3]["close_price_1day"] - @prediction_top10_u[3]["close_price_org"])/@prediction_top10_u[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_u = BigDecimal(((@prediction_top10_u[4]["close_price_1day"] - @prediction_top10_u[4]["close_price_org"])/@prediction_top10_u[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_u = BigDecimal(((@prediction_top10_u[5]["close_price_1day"] - @prediction_top10_u[5]["close_price_org"])/@prediction_top10_u[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_u = BigDecimal(((@prediction_top10_u[6]["close_price_1day"] - @prediction_top10_u[6]["close_price_org"])/@prediction_top10_u[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_u = BigDecimal(((@prediction_top10_u[7]["close_price_1day"] - @prediction_top10_u[7]["close_price_org"])/@prediction_top10_u[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_u = BigDecimal(((@prediction_top10_u[8]["close_price_1day"] - @prediction_top10_u[8]["close_price_org"])/@prediction_top10_u[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_u = BigDecimal(((@prediction_top10_u[9]["close_price_1day"] - @prediction_top10_u[9]["close_price_org"])/@prediction_top10_u[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "5" then
        top1_return_u = BigDecimal(((@prediction_top10_u[0]["close_price_5day"] - @prediction_top10_u[0]["close_price_org"])/@prediction_top10_u[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_u = BigDecimal(((@prediction_top10_u[1]["close_price_5day"] - @prediction_top10_u[1]["close_price_org"])/@prediction_top10_u[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_u = BigDecimal(((@prediction_top10_u[2]["close_price_5day"] - @prediction_top10_u[2]["close_price_org"])/@prediction_top10_u[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_u = BigDecimal(((@prediction_top10_u[3]["close_price_5day"] - @prediction_top10_u[3]["close_price_org"])/@prediction_top10_u[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_u = BigDecimal(((@prediction_top10_u[4]["close_price_5day"] - @prediction_top10_u[4]["close_price_org"])/@prediction_top10_u[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_u = BigDecimal(((@prediction_top10_u[5]["close_price_5day"] - @prediction_top10_u[5]["close_price_org"])/@prediction_top10_u[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_u = BigDecimal(((@prediction_top10_u[6]["close_price_5day"] - @prediction_top10_u[6]["close_price_org"])/@prediction_top10_u[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_u = BigDecimal(((@prediction_top10_u[7]["close_price_5day"] - @prediction_top10_u[7]["close_price_org"])/@prediction_top10_u[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_u = BigDecimal(((@prediction_top10_u[8]["close_price_5day"] - @prediction_top10_u[8]["close_price_org"])/@prediction_top10_u[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_u = BigDecimal(((@prediction_top10_u[9]["close_price_5day"] - @prediction_top10_u[9]["close_price_org"])/@prediction_top10_u[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "10" then
        top1_return_u = BigDecimal(((@prediction_top10_u[0]["close_price_10day"] - @prediction_top10_u[0]["close_price_org"])/@prediction_top10_u[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_u = BigDecimal(((@prediction_top10_u[1]["close_price_10day"] - @prediction_top10_u[1]["close_price_org"])/@prediction_top10_u[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_u = BigDecimal(((@prediction_top10_u[2]["close_price_10day"] - @prediction_top10_u[2]["close_price_org"])/@prediction_top10_u[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_u = BigDecimal(((@prediction_top10_u[3]["close_price_10day"] - @prediction_top10_u[3]["close_price_org"])/@prediction_top10_u[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_u = BigDecimal(((@prediction_top10_u[4]["close_price_10day"] - @prediction_top10_u[4]["close_price_org"])/@prediction_top10_u[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_u = BigDecimal(((@prediction_top10_u[5]["close_price_10day"] - @prediction_top10_u[5]["close_price_org"])/@prediction_top10_u[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_u = BigDecimal(((@prediction_top10_u[6]["close_price_10day"] - @prediction_top10_u[6]["close_price_org"])/@prediction_top10_u[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_u = BigDecimal(((@prediction_top10_u[7]["close_price_10day"] - @prediction_top10_u[7]["close_price_org"])/@prediction_top10_u[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_u = BigDecimal(((@prediction_top10_u[8]["close_price_10day"] - @prediction_top10_u[8]["close_price_org"])/@prediction_top10_u[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_u = BigDecimal(((@prediction_top10_u[9]["close_price_10day"] - @prediction_top10_u[9]["close_price_org"])/@prediction_top10_u[9]["close_price_org"])*100.to_d).floor(2).to_f
    end


    #category = [1,3,5,7]
    #category = [1111,2222,3333,4444,5555,6666,7777,8888,9999,0000]
    current_quantity_u_return = [top1_return_u,top2_return_u,top3_return_u,top4_return_u,top5_return_u,top6_return_u,top7_return_u,top8_return_u,top9_return_u,top10_return_u].sort
    #current_quantity_u = [{y: top1_return_u, name: @prediction_top10_u[0]["mkt_ticker_code"]},{y: top2_return_u, name: @prediction_top10_u[1]["mkt_ticker_code"]},{y: top3_return_u, name: @prediction_top10_u[2]["mkt_ticker_code"]},{y: top4_return_u, name: @prediction_top10_u[3]["mkt_ticker_code"]},{y: top5_return_u, name: @prediction_top10_u[4]["mkt_ticker_code"]},{y: top6_return_u, name: @prediction_top10_u[5]["mkt_ticker_code"]},{y: top7_return_u, name: @prediction_top10_u[6]["mkt_ticker_code"]},{y: top8_return_u, name: @prediction_top10_u[7]["mkt_ticker_code"]},{y: top9_return_u, name: @prediction_top10_u[8]["mkt_ticker_code"]},{y: top10_return_u, name: @prediction_top10_u[9]["mkt_ticker_code"]}]
    #current_quantity_u = [{y: top1_return_u, name: @prediction_top10_u[0]["mkt_ticker_code"]},{y: top2_return_u, name: @prediction_top10_u[1]["mkt_ticker_code"]},{y: top3_return_u, name: @prediction_top10_u[2]["mkt_ticker_code"]},{y: top4_return_u, name: @prediction_top10_u[3]["mkt_ticker_code"]},{y: top5_return_u, name: @prediction_top10_u[4]["mkt_ticker_code"]},{y: top6_return_u, name: @prediction_top10_u[5]["mkt_ticker_code"]},{y: top7_return_u, name: @prediction_top10_u[6]["mkt_ticker_code"]},{y: top8_return_u, name: @prediction_top10_u[7]["mkt_ticker_code"]},{y: top9_return_u, name: @prediction_top10_u[8]["mkt_ticker_code"]},{y: top10_return_u, name: @prediction_top10_u[9]["mkt_ticker_code"]}].sort_by{ |_, v| v }.reverse
    current_quantity_u = [{y: top1_return_u, name: @prediction_top10_u[0]["mkt_ticker_code"][11, 15]},{y: top2_return_u, name: @prediction_top10_u[1]["mkt_ticker_code"][11, 15]},{y: top3_return_u, name: @prediction_top10_u[2]["mkt_ticker_code"][11, 15]},{y: top4_return_u, name: @prediction_top10_u[3]["mkt_ticker_code"][11, 15]},{y: top5_return_u, name: @prediction_top10_u[4]["mkt_ticker_code"][11, 15]},{y: top6_return_u, name: @prediction_top10_u[5]["mkt_ticker_code"][11, 15]},{y: top7_return_u, name: @prediction_top10_u[6]["mkt_ticker_code"][11, 15]},{y: top8_return_u, name: @prediction_top10_u[7]["mkt_ticker_code"][11, 15]},{y: top9_return_u, name: @prediction_top10_u[8]["mkt_ticker_code"][11, 15]},{y: top10_return_u, name: @prediction_top10_u[9]["mkt_ticker_code"][11, 15]}].sort_by{ |_, v| v }

    @ai_graph_u = LazyHighCharts::HighChart.new('graph_u') do |f|
      f.title(text: 'リスクとリターン 買い')
      #f.xAxis(categories: category)
      f.xAxis(categories: current_quantity_u_return)
      #f.series(name: '銘柄名称', type: 'scatter', data: current_quantity_u)
      f.series(name: '銘柄コード', type: 'scatter', data: current_quantity_u)
      #f.tooltip({
      #  headerFormat: '<span style="font-size:11px">{this.point.ticker}</span><br>',
      #  pointFormat: '<b>{point.y:.2f}</b>'
      #})
      f.tooltip({
        pointFormat: '<b>{point.name}</b><br><b>{point.y:.2f}</b>'
      })
    end

    #TOP10取得 売り グラフ
    if params[:d] == "1" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_1day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_1day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_1day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_1day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_1day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_1day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_1day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_1day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_1day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_1day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "5" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_5day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_5day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_5day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_5day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_5day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_5day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_5day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_5day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_5day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_5day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "10" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_10day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_10day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_10day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_10day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_10day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_10day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_10day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_10day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_10day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_10day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    end


    #category = [1,3,5,7]
    #current_quantity_d = [top1_return_d,top2_return_d,top3_return_d,top4_return_d,top5_return_d,top6_return_d,top7_return_d,top8_return_d,top9_return_d,top10_return_d].sort

    #category = [1,3,5,7]
    #category = [1111,2222,3333,4444,5555,6666,7777,8888,9999,0000]
    current_quantity_d_return = [top1_return_d,top2_return_d,top3_return_d,top4_return_d,top5_return_d,top6_return_d,top7_return_d,top8_return_d,top9_return_d,top10_return_d].sort
    #current_quantity_d = [{y: top1_return_d, name: @prediction_top10_d[0]["mkt_ticker_code"]},{y: top2_return_d, name: @prediction_top10_d[1]["mkt_ticker_code"]},{y: top3_return_d, name: @prediction_top10_d[2]["mkt_ticker_code"]},{y: top4_return_d, name: @prediction_top10_d[3]["mkt_ticker_code"]},{y: top5_return_d, name: @prediction_top10_d[4]["mkt_ticker_code"]},{y: top6_return_d, name: @prediction_top10_d[5]["mkt_ticker_code"]},{y: top7_return_d, name: @prediction_top10_d[6]["mkt_ticker_code"]},{y: top8_return_d, name: @prediction_top10_d[7]["mkt_ticker_code"]},{y: top9_return_d, name: @prediction_top10_d[8]["mkt_ticker_code"]},{y: top10_return_d, name: @prediction_top10_d[9]["mkt_ticker_code"]}]
    current_quantity_d = [{y: top1_return_d, name: @prediction_top10_d[0]["mkt_ticker_code"][11, 15]},{y: top2_return_d, name: @prediction_top10_d[1]["mkt_ticker_code"][11, 15]},{y: top3_return_d, name: @prediction_top10_d[2]["mkt_ticker_code"][11, 15]},{y: top4_return_d, name: @prediction_top10_d[3]["mkt_ticker_code"][11, 15]},{y: top5_return_d, name: @prediction_top10_d[4]["mkt_ticker_code"][11, 15]},{y: top6_return_d, name: @prediction_top10_d[5]["mkt_ticker_code"][11, 15]},{y: top7_return_d, name: @prediction_top10_d[6]["mkt_ticker_code"][11, 15]},{y: top8_return_d, name: @prediction_top10_d[7]["mkt_ticker_code"][11, 15]},{y: top9_return_d, name: @prediction_top10_d[8]["mkt_ticker_code"][11, 15]},{y: top10_return_d, name: @prediction_top10_d[9]["mkt_ticker_code"][11, 15]}].sort_by{ |_, v| v }


    @ai_graph_d = LazyHighCharts::HighChart.new('graph_d') do |f|
      f.title(text: 'リスクとリターン 売り')
      #f.xAxis(categories: category)
      f.xAxis(categories: current_quantity_d_return)
      f.series(name: '銘柄コード', type: 'scatter', data: current_quantity_d)
      f.tooltip({
        pointFormat: '<b>{point.name}</b><br><b>{point.y:.2f}</b>'
      })
    end


    #トレンドシグナル分布推移グラフ
    if params[:d] == "1" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_1day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_1day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_1day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_1day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_1day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_1day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_1day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_1day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_1day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_1day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "5" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_5day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_5day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_5day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_5day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_5day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_5day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_5day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_5day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_5day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_5day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "10" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_10day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_10day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_10day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_10day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_10day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_10day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_10day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_10day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_10day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_10day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    end


    buy = [1,3,5,7,9,11,13,15,17,19,23,24]
    neutral = [2,4,6,8,9,10,13,15,17,19,23,24]
    sell = [1,4,5,6,9,13,16,19,22,23,24,25]
    topix = [2,4,6,8,9,12,14,16,18,23,24,25]




    @trend_signal_graph = LazyHighCharts::HighChart.new('trend_signal_graph') do |f|
    groupingUnits = [ ['week'], ['month', [1, 2, 3, 4, 6]] ]
      f.chart({
          type: 'areaspline'
      })
      f.title({
          text: ''
      })
      f.xAxis({
        categories: ['17/06', '17/07', '17/08', '17/09', '17/10', '17/11', '17/12', '18/01', '18/02', '18/03', '18/04', '18/05'],
        tickmarkPlacement: 'on',
        title: {
            enabled: false
        }
      })
      
      f.yAxis({
        title: {
            text: 'Percent',
        },
        offset: -40,
      })
      
      f.tooltip({
        pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y:,.0f} millions)<br/>',
        split: true
      })
      f.plotOptions({
          areaspline: {
              stacking: 'percent',
              lineColor: '#ffffff',
              lineWidth: 0
          }
      })
      f.series({
                   name: '買い',
                   data: buy,
                   color:'#315060',
                   dataGrouping: {
                       units: groupingUnits
                   }
               })
      f.series({
                   name: 'ニュートラル',
                   color:'#40593C',
                   data: neutral,
                   dataGrouping: {
                       units: groupingUnits
                   },
               })
      f.series({
                   name: '売り',
                   data: sell,
                   color:'#B23A59',   
                   dataGrouping: {
                       units: groupingUnits
                   },
               })
      f.series({
                   name: 'TOPIX',
                   type: "spline",
                   data: topix,
                   color:'#E3B72F',
                   dataGrouping: {
                       units: groupingUnits
                   },
               })
      f.legend({
              layout: 'horizontal'
          })
      f.exporting({
        enabled: false
      })
    end

  end
  
  
  
  
 ########2 columns######
    def ai_expro

    @rklist = {"1" => "値上がり率ランキング", "2" => "値下り率ランキング"}
#    @rkdate = {'1' => '1日後', '2' => '2日後', '3' => '3日後', '4' => '4日後', '5' => '5日後',
#               '6' => '6日後', '7' => '7日後', '8' => '8日後', '9' => '9日後', '10' => '10日後'}
    @rkdate = {'1' => '1日目',  '5' => '5日目', '10' => '10日後'}
    @mklist = []
    @seclist = []
    tmp = EqJsonData.where(["js_key = 'MarketInfo/MarketList.json'"]).order("js_seq")
    nowIdx = -1
    tmp.each do |d|
      if nowIdx != d["js_seq"] then
        @mklist << {}
        nowIdx = d["js_seq"]
      end
      @mklist[nowIdx].store(d["js_d_key"],d["js_d_value"])

    end
    tmp = EqJsonData.where(["js_key = 'MarketInfo/SectorList.json'"]).order("js_seq")
    nowIdx = -1
    tmp.each do |d|

      if nowIdx != d["js_seq"] then
        @seclist << {}
        nowIdx = d["js_seq"]
      end
      @seclist[nowIdx].store(d["js_d_key"],d["js_d_value"])
    end

    @rkinf = []
    if params[:r] == nil then
       @rkinf << "1"
       @rkinf << @mklist[0]["instance_no"]
       @rkinf << @seclist[0]["instance_no"]
       @rkinf << '1'
    else
       @rkinf << params[:r]
       @rkinf << params[:m]
       @rkinf << params[:s]
       @rkinf << params[:d]
    end

    if params[:d] == nil then
      params[:d] = "1"
    end


    url = API_SERVER_URL + '/AiMarketinfo/RankingDataList?days=' +
          @rkinf[3] + '&rankingType=' + @rkinf[0] + '&Market=' + @rkinf[1] + '&Sector=' + @rkinf[2] + '&pageSize=60'
    # url = 'http://192.168.1.100/AI_kabuapi/api/AiMarketinfo/RankingDataList?days=' +
    #         @rkinf[3] + '&rankingType=' + @rkinf[0] + '&Market=' + @rkinf[1] + '&Sector=' + @rkinf[2] + '&pageSize=60'
    #
    @info_Ranking = GetJsonData(url)
    print url
    if @info_Ranking.is_a?(Array)
      @rkdata = Kaminari.paginate_array(@info_Ranking).page(params[:page]).per(20)
    end


    #的中率取得
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictHitInfo'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictHitInfo'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictHitInfo'
    #@prediction_hit = GetJsonData(url)
    @prediction_hit = getPredictHit

    #売買予想比率
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictBuySellInfo'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictBuySellInfo'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictBuySellInfo'
    @prediction_buysellinfo = [] 
    @prediction_buysellinfo << getTrendData(1)
    @prediction_buysellinfo << getTrendData(5)
    @prediction_buysellinfo << getTrendData(10)
    
    #トレンドシグナル分布
    strDataSql = " select 1 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = 1 and p_updown > 0  union  select 0 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = 1 and p_updown = 0 union select -1 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = 1 and p_updown < 0"
    trends = ActiveRecord::Base.connection.select_all(strDataSql)
    @predictTrend = @prediction_buysellinfo[0] 

    #TOP10取得 買い
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'u'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'u'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'u'
    #@prediction_top10_u = GetJsonData(url)


    if params[:d].present?  and  (params[:d].to_i >0) then
      days = params[:d]

    else
      days = 1
    end
    
  
    
    
    #for new rank requirement
    
    rankd = 'topix'
    if params[:rankd].present? then
       rankd = params[:rankd]
    end

    #end of add





    @prediction_top10_u = getPredictData(days,rankd," desc ")


    #TOP10取得 売り
    #  url = API_SERVER_URL + '/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'd'
    # url = 'http://192.168.1.100/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'd'
    # url = 'http://192.168.1.9/kabuapi/api/AiMarketInfo/AIPredictTop10?flg=' + params[:d] + 'd'
    @prediction_top10_d = getPredictData(days,rankd," ")

    ##add search 
    if params[:tick_code].present? then
       
      @pre_dataj,@tickerj,@tickern = getPreData( params[:tick_code] ,params[:ratios] )
      
      if @pre_dataj.length < 2 then
        @pre_dataj,@tickerj,@tickern = getPreData(@prediction_top10_u[0]["market_ticker_code"] , params[:ratios])
        @nodataj=1
        @nodatan = params[:tick_code]
      else
        @nodataj=0
      end
      
    else
      @nodataj=0
      @pre_dataj,@tickerj,@tickern = getPreData(@prediction_top10_u[0]["market_ticker_code"] , params[:ratios])
      
    end
    
    
    

    #TOP10取得 買い グラフ
    if params[:d] == "1" then
        top1_return_u = BigDecimal(((@prediction_top10_u[0]["close_price_1day"] - @prediction_top10_u[0]["close_price_org"])/@prediction_top10_u[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_u = BigDecimal(((@prediction_top10_u[1]["close_price_1day"] - @prediction_top10_u[1]["close_price_org"])/@prediction_top10_u[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_u = BigDecimal(((@prediction_top10_u[2]["close_price_1day"] - @prediction_top10_u[2]["close_price_org"])/@prediction_top10_u[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_u = BigDecimal(((@prediction_top10_u[3]["close_price_1day"] - @prediction_top10_u[3]["close_price_org"])/@prediction_top10_u[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_u = BigDecimal(((@prediction_top10_u[4]["close_price_1day"] - @prediction_top10_u[4]["close_price_org"])/@prediction_top10_u[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_u = BigDecimal(((@prediction_top10_u[5]["close_price_1day"] - @prediction_top10_u[5]["close_price_org"])/@prediction_top10_u[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_u = BigDecimal(((@prediction_top10_u[6]["close_price_1day"] - @prediction_top10_u[6]["close_price_org"])/@prediction_top10_u[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_u = BigDecimal(((@prediction_top10_u[7]["close_price_1day"] - @prediction_top10_u[7]["close_price_org"])/@prediction_top10_u[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_u = BigDecimal(((@prediction_top10_u[8]["close_price_1day"] - @prediction_top10_u[8]["close_price_org"])/@prediction_top10_u[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_u = BigDecimal(((@prediction_top10_u[9]["close_price_1day"] - @prediction_top10_u[9]["close_price_org"])/@prediction_top10_u[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "5" then
        top1_return_u = BigDecimal(((@prediction_top10_u[0]["close_price_5day"] - @prediction_top10_u[0]["close_price_org"])/@prediction_top10_u[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_u = BigDecimal(((@prediction_top10_u[1]["close_price_5day"] - @prediction_top10_u[1]["close_price_org"])/@prediction_top10_u[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_u = BigDecimal(((@prediction_top10_u[2]["close_price_5day"] - @prediction_top10_u[2]["close_price_org"])/@prediction_top10_u[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_u = BigDecimal(((@prediction_top10_u[3]["close_price_5day"] - @prediction_top10_u[3]["close_price_org"])/@prediction_top10_u[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_u = BigDecimal(((@prediction_top10_u[4]["close_price_5day"] - @prediction_top10_u[4]["close_price_org"])/@prediction_top10_u[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_u = BigDecimal(((@prediction_top10_u[5]["close_price_5day"] - @prediction_top10_u[5]["close_price_org"])/@prediction_top10_u[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_u = BigDecimal(((@prediction_top10_u[6]["close_price_5day"] - @prediction_top10_u[6]["close_price_org"])/@prediction_top10_u[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_u = BigDecimal(((@prediction_top10_u[7]["close_price_5day"] - @prediction_top10_u[7]["close_price_org"])/@prediction_top10_u[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_u = BigDecimal(((@prediction_top10_u[8]["close_price_5day"] - @prediction_top10_u[8]["close_price_org"])/@prediction_top10_u[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_u = BigDecimal(((@prediction_top10_u[9]["close_price_5day"] - @prediction_top10_u[9]["close_price_org"])/@prediction_top10_u[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "10" then
        top1_return_u = BigDecimal(((@prediction_top10_u[0]["close_price_10day"] - @prediction_top10_u[0]["close_price_org"])/@prediction_top10_u[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_u = BigDecimal(((@prediction_top10_u[1]["close_price_10day"] - @prediction_top10_u[1]["close_price_org"])/@prediction_top10_u[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_u = BigDecimal(((@prediction_top10_u[2]["close_price_10day"] - @prediction_top10_u[2]["close_price_org"])/@prediction_top10_u[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_u = BigDecimal(((@prediction_top10_u[3]["close_price_10day"] - @prediction_top10_u[3]["close_price_org"])/@prediction_top10_u[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_u = BigDecimal(((@prediction_top10_u[4]["close_price_10day"] - @prediction_top10_u[4]["close_price_org"])/@prediction_top10_u[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_u = BigDecimal(((@prediction_top10_u[5]["close_price_10day"] - @prediction_top10_u[5]["close_price_org"])/@prediction_top10_u[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_u = BigDecimal(((@prediction_top10_u[6]["close_price_10day"] - @prediction_top10_u[6]["close_price_org"])/@prediction_top10_u[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_u = BigDecimal(((@prediction_top10_u[7]["close_price_10day"] - @prediction_top10_u[7]["close_price_org"])/@prediction_top10_u[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_u = BigDecimal(((@prediction_top10_u[8]["close_price_10day"] - @prediction_top10_u[8]["close_price_org"])/@prediction_top10_u[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_u = BigDecimal(((@prediction_top10_u[9]["close_price_10day"] - @prediction_top10_u[9]["close_price_org"])/@prediction_top10_u[9]["close_price_org"])*100.to_d).floor(2).to_f
    end


    #category = [1,3,5,7]
    #category = [1111,2222,3333,4444,5555,6666,7777,8888,9999,0000]
    current_quantity_u_return = [top1_return_u,top2_return_u,top3_return_u,top4_return_u,top5_return_u,top6_return_u,top7_return_u,top8_return_u,top9_return_u,top10_return_u].sort
    #current_quantity_u = [{y: top1_return_u, name: @prediction_top10_u[0]["mkt_ticker_code"]},{y: top2_return_u, name: @prediction_top10_u[1]["mkt_ticker_code"]},{y: top3_return_u, name: @prediction_top10_u[2]["mkt_ticker_code"]},{y: top4_return_u, name: @prediction_top10_u[3]["mkt_ticker_code"]},{y: top5_return_u, name: @prediction_top10_u[4]["mkt_ticker_code"]},{y: top6_return_u, name: @prediction_top10_u[5]["mkt_ticker_code"]},{y: top7_return_u, name: @prediction_top10_u[6]["mkt_ticker_code"]},{y: top8_return_u, name: @prediction_top10_u[7]["mkt_ticker_code"]},{y: top9_return_u, name: @prediction_top10_u[8]["mkt_ticker_code"]},{y: top10_return_u, name: @prediction_top10_u[9]["mkt_ticker_code"]}]
    #current_quantity_u = [{y: top1_return_u, name: @prediction_top10_u[0]["mkt_ticker_code"]},{y: top2_return_u, name: @prediction_top10_u[1]["mkt_ticker_code"]},{y: top3_return_u, name: @prediction_top10_u[2]["mkt_ticker_code"]},{y: top4_return_u, name: @prediction_top10_u[3]["mkt_ticker_code"]},{y: top5_return_u, name: @prediction_top10_u[4]["mkt_ticker_code"]},{y: top6_return_u, name: @prediction_top10_u[5]["mkt_ticker_code"]},{y: top7_return_u, name: @prediction_top10_u[6]["mkt_ticker_code"]},{y: top8_return_u, name: @prediction_top10_u[7]["mkt_ticker_code"]},{y: top9_return_u, name: @prediction_top10_u[8]["mkt_ticker_code"]},{y: top10_return_u, name: @prediction_top10_u[9]["mkt_ticker_code"]}].sort_by{ |_, v| v }.reverse
    current_quantity_u = [{y: top1_return_u, name: @prediction_top10_u[0]["mkt_ticker_code"][11, 15]},{y: top2_return_u, name: @prediction_top10_u[1]["mkt_ticker_code"][11, 15]},{y: top3_return_u, name: @prediction_top10_u[2]["mkt_ticker_code"][11, 15]},{y: top4_return_u, name: @prediction_top10_u[3]["mkt_ticker_code"][11, 15]},{y: top5_return_u, name: @prediction_top10_u[4]["mkt_ticker_code"][11, 15]},{y: top6_return_u, name: @prediction_top10_u[5]["mkt_ticker_code"][11, 15]},{y: top7_return_u, name: @prediction_top10_u[6]["mkt_ticker_code"][11, 15]},{y: top8_return_u, name: @prediction_top10_u[7]["mkt_ticker_code"][11, 15]},{y: top9_return_u, name: @prediction_top10_u[8]["mkt_ticker_code"][11, 15]},{y: top10_return_u, name: @prediction_top10_u[9]["mkt_ticker_code"][11, 15]}].sort_by{ |_, v| v }

    @ai_graph_u = LazyHighCharts::HighChart.new('graph_u') do |f|
      f.title(text: 'リスクとリターン 買い')
      #f.xAxis(categories: category)
      f.xAxis(categories: current_quantity_u_return)
      #f.series(name: '銘柄名称', type: 'scatter', data: current_quantity_u)
      f.series(name: '銘柄コード', type: 'scatter', data: current_quantity_u)
      #f.tooltip({
      #  headerFormat: '<span style="font-size:11px">{this.point.ticker}</span><br>',
      #  pointFormat: '<b>{point.y:.2f}</b>'
      #})
      f.tooltip({
        pointFormat: '<b>{point.name}</b><br><b>{point.y:.2f}</b>'
      })
    end

    #TOP10取得 売り グラフ
    if params[:d] == "1" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_1day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_1day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_1day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_1day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_1day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_1day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_1day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_1day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_1day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_1day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "5" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_5day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_5day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_5day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_5day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_5day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_5day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_5day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_5day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_5day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_5day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "10" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_10day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_10day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_10day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_10day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_10day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_10day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_10day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_10day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_10day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_10day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    end


    #category = [1,3,5,7]
    #current_quantity_d = [top1_return_d,top2_return_d,top3_return_d,top4_return_d,top5_return_d,top6_return_d,top7_return_d,top8_return_d,top9_return_d,top10_return_d].sort

    #category = [1,3,5,7]
    #category = [1111,2222,3333,4444,5555,6666,7777,8888,9999,0000]
    current_quantity_d_return = [top1_return_d,top2_return_d,top3_return_d,top4_return_d,top5_return_d,top6_return_d,top7_return_d,top8_return_d,top9_return_d,top10_return_d].sort
    #current_quantity_d = [{y: top1_return_d, name: @prediction_top10_d[0]["mkt_ticker_code"]},{y: top2_return_d, name: @prediction_top10_d[1]["mkt_ticker_code"]},{y: top3_return_d, name: @prediction_top10_d[2]["mkt_ticker_code"]},{y: top4_return_d, name: @prediction_top10_d[3]["mkt_ticker_code"]},{y: top5_return_d, name: @prediction_top10_d[4]["mkt_ticker_code"]},{y: top6_return_d, name: @prediction_top10_d[5]["mkt_ticker_code"]},{y: top7_return_d, name: @prediction_top10_d[6]["mkt_ticker_code"]},{y: top8_return_d, name: @prediction_top10_d[7]["mkt_ticker_code"]},{y: top9_return_d, name: @prediction_top10_d[8]["mkt_ticker_code"]},{y: top10_return_d, name: @prediction_top10_d[9]["mkt_ticker_code"]}]
    current_quantity_d = [{y: top1_return_d, name: @prediction_top10_d[0]["mkt_ticker_code"][11, 15]},{y: top2_return_d, name: @prediction_top10_d[1]["mkt_ticker_code"][11, 15]},{y: top3_return_d, name: @prediction_top10_d[2]["mkt_ticker_code"][11, 15]},{y: top4_return_d, name: @prediction_top10_d[3]["mkt_ticker_code"][11, 15]},{y: top5_return_d, name: @prediction_top10_d[4]["mkt_ticker_code"][11, 15]},{y: top6_return_d, name: @prediction_top10_d[5]["mkt_ticker_code"][11, 15]},{y: top7_return_d, name: @prediction_top10_d[6]["mkt_ticker_code"][11, 15]},{y: top8_return_d, name: @prediction_top10_d[7]["mkt_ticker_code"][11, 15]},{y: top9_return_d, name: @prediction_top10_d[8]["mkt_ticker_code"][11, 15]},{y: top10_return_d, name: @prediction_top10_d[9]["mkt_ticker_code"][11, 15]}].sort_by{ |_, v| v }


    @ai_graph_d = LazyHighCharts::HighChart.new('graph_d') do |f|
      f.title(text: 'リスクとリターン 売り')
      #f.xAxis(categories: category)
      f.xAxis(categories: current_quantity_d_return)
      f.series(name: '銘柄コード', type: 'scatter', data: current_quantity_d)
      f.tooltip({
        pointFormat: '<b>{point.name}</b><br><b>{point.y:.2f}</b>'
      })
    end


    #トレンドシグナル分布推移グラフ
    if params[:d] == "1" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_1day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_1day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_1day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_1day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_1day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_1day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_1day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_1day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_1day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_1day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "5" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_5day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_5day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_5day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_5day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_5day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_5day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_5day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_5day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_5day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_5day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    elsif params[:d] == "10" then
        top1_return_d = BigDecimal(((@prediction_top10_d[0]["close_price_10day"] - @prediction_top10_d[0]["close_price_org"])/@prediction_top10_d[0]["close_price_org"])*100.to_d).floor(2).to_f
        top2_return_d = BigDecimal(((@prediction_top10_d[1]["close_price_10day"] - @prediction_top10_d[1]["close_price_org"])/@prediction_top10_d[1]["close_price_org"])*100.to_d).floor(2).to_f
        top3_return_d = BigDecimal(((@prediction_top10_d[2]["close_price_10day"] - @prediction_top10_d[2]["close_price_org"])/@prediction_top10_d[2]["close_price_org"])*100.to_d).floor(2).to_f
        top4_return_d = BigDecimal(((@prediction_top10_d[3]["close_price_10day"] - @prediction_top10_d[3]["close_price_org"])/@prediction_top10_d[3]["close_price_org"])*100.to_d).floor(2).to_f
        top5_return_d = BigDecimal(((@prediction_top10_d[4]["close_price_10day"] - @prediction_top10_d[4]["close_price_org"])/@prediction_top10_d[4]["close_price_org"])*100.to_d).floor(2).to_f
        top6_return_d = BigDecimal(((@prediction_top10_d[5]["close_price_10day"] - @prediction_top10_d[5]["close_price_org"])/@prediction_top10_d[5]["close_price_org"])*100.to_d).floor(2).to_f
        top7_return_d = BigDecimal(((@prediction_top10_d[6]["close_price_10day"] - @prediction_top10_d[6]["close_price_org"])/@prediction_top10_d[6]["close_price_org"])*100.to_d).floor(2).to_f
        top8_return_d = BigDecimal(((@prediction_top10_d[7]["close_price_10day"] - @prediction_top10_d[7]["close_price_org"])/@prediction_top10_d[7]["close_price_org"])*100.to_d).floor(2).to_f
        top9_return_d = BigDecimal(((@prediction_top10_d[8]["close_price_10day"] - @prediction_top10_d[8]["close_price_org"])/@prediction_top10_d[8]["close_price_org"])*100.to_d).floor(2).to_f
        top10_return_d = BigDecimal(((@prediction_top10_d[9]["close_price_10day"] - @prediction_top10_d[9]["close_price_org"])/@prediction_top10_d[9]["close_price_org"])*100.to_d).floor(2).to_f
    end


    buy = [1,3,5,7,9,11,13,15,17,19,23,24]
    neutral = [2,4,6,8,9,10,13,15,17,19,23,24]
    sell = [1,4,5,6,9,13,16,19,22,23,24,25]
    topix = [2,4,6,8,9,12,14,16,18,23,24,25]




    @trend_signal_graph = LazyHighCharts::HighChart.new('trend_signal_graph') do |f|
    groupingUnits = [ ['week'], ['month', [1, 2, 3, 4, 6]] ]
      f.chart({
          type: 'areaspline'
      })
      f.title({
          text: ''
      })
      f.xAxis({
        categories: ['17/06', '17/07', '17/08', '17/09', '17/10', '17/11', '17/12', '18/01', '18/02', '18/03', '18/04', '18/05'],
        tickmarkPlacement: 'on',
        title: {
            enabled: false
        }
      })
      
      f.yAxis({
        title: {
            text: 'Percent',
        },
        offset: -40,
      })
      
      f.tooltip({
        pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y:,.0f} millions)<br/>',
        split: true
      })
      f.plotOptions({
          areaspline: {
              stacking: 'percent',
              lineColor: '#ffffff',
              lineWidth: 0
          }
      })
      f.series({
                   name: '買い',
                   data: buy,
                   color:'#315060',
                   dataGrouping: {
                       units: groupingUnits
                   }
               })
      f.series({
                   name: 'ニュートラル',
                   color:'#40593C',
                   data: neutral,
                   dataGrouping: {
                       units: groupingUnits
                   },
               })
      f.series({
                   name: '売り',
                   data: sell,
                   color:'#B23A59',   
                   dataGrouping: {
                       units: groupingUnits
                   },
               })
      f.series({
                   name: 'TOPIX',
                   type: "spline",
                   data: topix,
                   color:'#E3B72F',
                   dataGrouping: {
                       units: groupingUnits
                   },
               })
      f.legend({
              layout: 'horizontal'
          })
      f.exporting({
        enabled: false
      })
    end

  end
  
  
  


  
  
  
  
  def getTrendData(days)
    strDataSql = " select 1 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = " + days.to_s + " and p_updown > 0  union  select 0 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = " + days.to_s  + " and p_updown = 0 union select -1 as type ,count(mk_d) as ct from securities_predict_lists where mk_d = (select max(max_predict_date) from securities_used_dates) and idx = " + days.to_s  + " and p_updown < 0"
    trends = ActiveRecord::Base.connection.select_all(strDataSql)
    pTrend = {}
    allcount = 0
    trends.each do |d|
      allcount = allcount + d["ct"]
      if d["type"] == 1 then
        pTrend["up"] = d["ct"]
      elsif d["type"] == -1 then
        pTrend["down"] = d["ct"]
      else
        pTrend["same"] = d["ct"]
      end
    end
    pTrend["all"] = allcount
    pTrend["uprate"] = (pTrend["up"].to_f * 100.0 / allcount.to_f).round(2)
    pTrend["downrate"] = (pTrend["down"].to_f * 100.0 / allcount.to_f).round(2)
    pTrend["samerate"] = (pTrend["same"].to_f * 100.0 / allcount.to_f).round(2)
    return pTrend
  end
 
  def getPredictHit
    strDataSql = "select DATE_FORMAT(mk_d,'%Y-%m-%d') md ,DATE_FORMAT(mk_p_d,'%Y-%m-%d') pd ,idx,trend,p_r,count from securities_predict_statistics where mk_p_d = (select max(mk_p_d) from securities_predict_statistics where mk_p_d < '9999-01-01' )"
    mydatas = ActiveRecord::Base.connection.select_all(strDataSql)
    predicthit = {}
    predicthit["hit_rate_1day_up"]=0
    predicthit["hit_rate_1day_up_count"]=0
    predicthit["hit_rate_1day_up_all_count"]=0
    predicthit["hit_rate_1day_up_0_3"]=0
    predicthit["hit_rate_1day_up_count_0_3"]=0
    predicthit["hit_rate_1day_up_all_count_0_3"]=0
    predicthit["hit_rate_1day_up_3_5"]=0
    predicthit["hit_rate_1day_up_count_3_5"]=0
    predicthit["hit_rate_1day_up_all_count_3_5"]=0
    predicthit["hit_rate_1day_up_5_"]=0
    predicthit["hit_rate_1day_up_count_5_"]=0
    predicthit["hit_rate_1day_up_all_count_5_"]=0
    predicthit["hit_rate_1day_down"]=0
    predicthit["hit_rate_1day_down_count"]=0
    predicthit["hit_rate_1day_down_all_count"]=0
    predicthit["hit_rate_1day_down_0_3"]=0
    predicthit["hit_rate_1day_down_count_0_3"]=0
    predicthit["hit_rate_1day_down_all_count_0_3"]=0
    predicthit["hit_rate_1day_down_3_5"]=0
    predicthit["hit_rate_1day_down_count_3_5"]=0
    predicthit["hit_rate_1day_down_all_count_3_5"]=0
    predicthit["hit_rate_1day_down_5_"]=0
    predicthit["hit_rate_1day_down_count_5_"]=0
    predicthit["hit_rate_1day_down_all_count_5_"]=0
    predicthit["hit_rate_1day_1p"]=0
    predicthit["hit_rate_1day_1p_count"]=0
    predicthit["hit_rate_1day_1p_all_count"]=0
    predicthit["hit_rate_5day_up"]=0
    predicthit["hit_rate_5day_up_count"]=0
    predicthit["hit_rate_5day_up_all_count"]=0
    predicthit["hit_rate_5day_up_0_3"]=0
    predicthit["hit_rate_5day_up_count_0_3"]=0
    predicthit["hit_rate_5day_up_all_count_0_3"]=0
    predicthit["hit_rate_5day_up_3_5"]=0
    predicthit["hit_rate_5day_up_count_3_5"]=0
    predicthit["hit_rate_5day_up_all_count_3_5"]=0
    predicthit["hit_rate_5day_up_5_"]=0
    predicthit["hit_rate_5day_up_count_5_"]=0
    predicthit["hit_rate_5day_up_all_count_5_"]=0
    predicthit["hit_rate_5day_down"]=0
    predicthit["hit_rate_5day_down_count"]=0
    predicthit["hit_rate_5day_down_all_count"]=0
    predicthit["hit_rate_5day_down_0_3"]=0
    predicthit["hit_rate_5day_down_count_0_3"]=0
    predicthit["hit_rate_5day_down_all_count_0_3"]=0
    predicthit["hit_rate_5day_down_3_5"]=0
    predicthit["hit_rate_5day_down_count_3_5"]=0
    predicthit["hit_rate_5day_down_all_count_3_5"]=0
    predicthit["hit_rate_5day_down_5_"]=0
    predicthit["hit_rate_5day_down_count_5_"]=0
    predicthit["hit_rate_5day_down_all_count_5_"]=0
    predicthit["hit_rate_5day_1p"]=0
    predicthit["hit_rate_5day_1p_count"]=0
    predicthit["hit_rate_5day_1p_all_count"]=0
    predicthit["hit_rate_10day_up"]=0
    predicthit["hit_rate_10day_up_count"]=0
    predicthit["hit_rate_10day_up_all_count"]=0
    predicthit["hit_rate_10day_up_0_3"]=0
    predicthit["hit_rate_10day_up_count_0_3"]=0
    predicthit["hit_rate_10day_up_all_count_0_3"]=0
    predicthit["hit_rate_10day_up_3_5"]=0
    predicthit["hit_rate_10day_up_count_3_5"]=0
    predicthit["hit_rate_10day_up_all_count_3_5"]=0
    predicthit["hit_rate_10day_up_5_"]=0
    predicthit["hit_rate_10day_up_count_5_"]=0
    predicthit["hit_rate_10day_up_all_count_5_"]=0
    predicthit["hit_rate_10day_down"]=0
    predicthit["hit_rate_10day_down_count"]=0
    predicthit["hit_rate_10day_down_all_count"]=0
    predicthit["hit_rate_10day_down_0_3"]=0
    predicthit["hit_rate_10day_down_count_0_3"]=0
    predicthit["hit_rate_10day_down_all_count_0_3"]=0
    predicthit["hit_rate_10day_down_3_5"]=0
    predicthit["hit_rate_10day_down_count_3_5"]=0
    predicthit["hit_rate_10day_down_all_count_3_5"]=0
    predicthit["hit_rate_10day_down_5_"]=0
    predicthit["hit_rate_10day_down_count_5_"]=0
    predicthit["hit_rate_10day_down_all_count_5_"]=0
    predicthit["hit_rate_10day_1p"]=0
    predicthit["hit_rate_10day_1p_count"]=0
    predicthit["hit_rate_10day_1p_all_count"]=0
    predicthit["hit_rate_1day_up_total"]=0
    predicthit["hit_rate_1day_up_count_total"]=0
    predicthit["hit_rate_1day_up_all_count_total"]=0
    predicthit["hit_rate_1day_up_0_3_total"]=0
    predicthit["hit_rate_1day_up_count_0_3_total"]=0
    predicthit["hit_rate_1day_up_all_count_0_3_total"]=0
    predicthit["hit_rate_1day_up_3_5_total"]=0
    predicthit["hit_rate_1day_up_count_3_5_total"]=0
    predicthit["hit_rate_1day_up_all_count_3_5_total"]=0
    predicthit["hit_rate_1day_up_5_total"]=0
    predicthit["hit_rate_1day_up_count_5_total"]=0
    predicthit["hit_rate_1day_up_all_count_5_total"]=0
    predicthit["hit_rate_1day_down_total"]=0
    predicthit["hit_rate_1day_down_count_total"]=0
    predicthit["hit_rate_1day_down_all_count_total"]=0
    predicthit["hit_rate_1day_down_0_3_total"]=0
    predicthit["hit_rate_1day_down_count_0_3_total"]=0
    predicthit["hit_rate_1day_down_all_count_0_3_total"]=0
    predicthit["hit_rate_1day_down_3_5_total"]=0
    predicthit["hit_rate_1day_down_count_3_5_total"]=0
    predicthit["hit_rate_1day_down_all_count_3_5_total"]=0
    predicthit["hit_rate_1day_down_5_total"]=0
    predicthit["hit_rate_1day_down_count_5_total"]=0
    predicthit["hit_rate_1day_down_all_count_5_total"]=0
    predicthit["hit_rate_1day_1p_total"]=0
    predicthit["hit_rate_1day_1p_count_total"]=0
    predicthit["hit_rate_1day_1p_all_count_total"]=0
    predicthit["hit_rate_5day_up_total"]=0
    predicthit["hit_rate_5day_up_count_total"]=0
    predicthit["hit_rate_5day_up_all_count_total"]=0
    predicthit["hit_rate_5day_up_0_3_total"]=0
    predicthit["hit_rate_5day_up_count_0_3_total"]=0
    predicthit["hit_rate_5day_up_all_count_0_3_total"]=0
    predicthit["hit_rate_5day_up_3_5_total"]=0
    predicthit["hit_rate_5day_up_count_3_5_total"]=0
    predicthit["hit_rate_5day_up_all_count_3_5_total"]=0
    predicthit["hit_rate_5day_up_5_total"]=0
    predicthit["hit_rate_5day_up_count_5_total"]=0
    predicthit["hit_rate_5day_up_all_count_5_total"]=0
    predicthit["hit_rate_5day_down_total"]=0
    predicthit["hit_rate_5day_down_count_total"]=0
    predicthit["hit_rate_5day_down_all_count_total"]=0
    predicthit["hit_rate_5day_down_0_3_total"]=0
    predicthit["hit_rate_5day_down_count_0_3_total"]=0
    predicthit["hit_rate_5day_down_all_count_0_3_total"]=0
    predicthit["hit_rate_5day_down_3_5_total"]=0
    predicthit["hit_rate_5day_down_count_3_5_total"]=0
    predicthit["hit_rate_5day_down_all_count_3_5_total"]=0
    predicthit["hit_rate_5day_down_5_total"]=0
    predicthit["hit_rate_5day_down_count_5_total"]=0
    predicthit["hit_rate_5day_down_all_count_5_total"]=0
    predicthit["hit_rate_5day_1p_total"]=0
    predicthit["hit_rate_5day_1p_count_total"]=0
    predicthit["hit_rate_5day_1p_all_count_total"]=0
    predicthit["hit_rate_10day_up_total"]=0
    predicthit["hit_rate_10day_up_count_total"]=0
    predicthit["hit_rate_10day_up_all_count_total"]=0
    predicthit["hit_rate_10day_up_0_3_total"]=0
    predicthit["hit_rate_10day_up_count_0_3_total"]=0
    predicthit["hit_rate_10day_up_all_count_0_3_total"]=0
    predicthit["hit_rate_10day_up_3_5_total"]=0
    predicthit["hit_rate_10day_up_count_3_5_total"]=0
    predicthit["hit_rate_10day_up_all_count_3_5_total"]=0
    predicthit["hit_rate_10day_up_5_total"]=0
    predicthit["hit_rate_10day_up_count_5_total"]=0
    predicthit["hit_rate_10day_up_all_count_5_total"]=0
    predicthit["hit_rate_10day_down_total"]=0
    predicthit["hit_rate_10day_down_count_total"]=0
    predicthit["hit_rate_10day_down_all_count_total"]=0
    predicthit["hit_rate_10day_down_0_3_total"]=0
    predicthit["hit_rate_10day_down_count_0_3_total"]=0
    predicthit["hit_rate_10day_down_all_count_0_3_total"]=0
    predicthit["hit_rate_10day_down_3_5_total"]=0
    predicthit["hit_rate_10day_down_count_3_5_total"]=0
    predicthit["hit_rate_10day_down_all_count_3_5_total"]=0
    predicthit["hit_rate_10day_down_5_total"]=0
    predicthit["hit_rate_10day_down_count_5_total"]=0
    predicthit["hit_rate_10day_down_all_count_5_total"]=0
    predicthit["hit_rate_10day_1p_total"]=0
    predicthit["hit_rate_10day_1p_count_total"]=0
    predicthit["hit_rate_10day_1p_all_count_total"]=0
    if mydatas.present? then
      mydatas.each do |d|
        keyname = "hit_rate_" + d["idx"].to_s + "day_"
        if d["trend"].abs <= 1 then
          if d["p_r"] == 0 then
            if d["md"] == '2010-01-01' then
              predicthit[keyname+"1p_all_count_total"] = predicthit[keyname + "1p_all_count_total"] + d["count"]
            else
              predicthit[keyname+"1p_all_count"] = predicthit[keyname + "1p_all_count"] + d["count"]
            end
          else
            if d["md"] == '2010-01-01' then
              predicthit[keyname+"1p_count_total"] = predicthit[keyname + "1p_count_total"] + d["count"]
            else
              predicthit[keyname+"1p_count"] = predicthit[keyname + "1p_count"] + d["count"]
            end
          end
        end
        if d["trend"] >= 0 then
          keyname = keyname + "up"
        else
          keyname = keyname + "down"
        end
        if d["p_r"] == 0 then
          keyname = keyname + "_all_count" 
        else
          keyname = keyname + "_count" 
        end
        if d["trend"].abs <= 3 then
          keyname = keyname + "_0_3"
        elsif d["trend"].abs <= 5 then
          keyname = keyname + "_3_5"
        else
          keyname = keyname + "_5_"
        end
        if d["md"] == '2010-01-01' then
          keyname = (keyname + "_total").sub(/__/,'_')
        else
          predicthit["mkt_date_" + d["idx"].to_s + "day"] = d["md"]
        end
        if not predicthit.has_key?(keyname) then
          logger.debug keyname
        else
          if d["trend"].abs > 1 then
            predicthit[keyname] = predicthit[keyname] + d["count"]
          end
        end
      end
    end
    if not predicthit.has_key?("mkt_date_10day") then
      predicthit["mkt_date_10day"] = "2018-11-06"
    end
    predicthit.keys.each do |k|
      if k.index("_all_count") != nil then
        if predicthit[k] > 0 then
          predicthit[k.sub(/_all_count/,'')] = predicthit[k.sub(/all_count/, "count")].to_f / predicthit[k].to_f
        end
      end
    end
    #logger.debug predicthit
    return [predicthit]
  end


#  modified, 20190312   Modify reason , a new table of index_securities be added into database , so the SQL usage be changed.
  def getPredictData(days,rankd,order)
    #strDataSql = "select t.rownum,DATE_FORMAT(t.mk_d,'%Y-%m-%d') md,DATE_FORMAT(a.mk_p_d,'%Y-%m-%d') pd,a.idx,a.ticker,b.eqty_name,a.baseprice, a.price from securities_predict_lists a, equity_issue b,(select @i := @i + 1 rownum, a.ticker,a.mk_d from (select @i := 0) dumy,securities_predict_lists as a where a.mk_d = (select max(max_predict_date) from securities_used_dates) and a.idx = " + days.to_s + " and a.p_updown is not null order by a.p_updown " + order + " limit 50) t where a.ticker = b.eqty_ticker and a.ticker = t.ticker and a.mk_d = t.mk_d and a.idx in (1,5,10) order by t.rownum,a.idx  limit 30;"

    if rankd =="nikkei" then
       strDataSql = "select  rownum,md,pd,idx,k.ticker,eqty_name,baseprice,price from (select sec_code as ticker,index_name from riskreport_development.index_securities) as f right join (select t.rownum,DATE_FORMAT(t.mk_d,'%Y-%m-%d') md,DATE_FORMAT(a.mk_p_d,'%Y-%m-%d') pd,a.idx,a.ticker,b.eqty_name,a.baseprice, a.price from securities_predict_lists a, equity_issue b,(select @i := @i + 1 rownum, a.ticker,a.mk_d from (select @i := 0) dumy,securities_predict_lists a where a.mk_d = (select max(max_predict_date) from securities_used_dates) and a.idx = " + days.to_s + " and a.p_updown is not null order by a.p_updown " + order + " limit 1000) t where a.ticker = b.eqty_ticker and a.ticker = t.ticker and a.mk_d = t.mk_d and a.idx in (1,5,10) order by t.rownum,a.idx "
       strDataSql = strDataSql +" "+ ")  as  k on f.ticker =k.ticker where index_name like "+ "'%"+rankd + "%'"+" order by rownum limit 30 ;"
    else
       strDataSql = "select  rownum,md,pd,idx,k.ticker,eqty_name,baseprice,price from (select sec_code as ticker,index_name from riskreport_development.index_securities) as f right join (select t.rownum,DATE_FORMAT(t.mk_d,'%Y-%m-%d') md,DATE_FORMAT(a.mk_p_d,'%Y-%m-%d') pd,a.idx,a.ticker,b.eqty_name,a.baseprice, a.price from securities_predict_lists a, equity_issue b,(select @i := @i + 1 rownum, a.ticker,a.mk_d from (select @i := 0) dumy,securities_predict_lists a where a.mk_d = (select max(max_predict_date) from securities_used_dates) and a.idx = " + days.to_s + " and a.p_updown is not null order by a.p_updown " + order + " limit 1000) t where a.ticker = b.eqty_ticker and a.ticker = t.ticker and a.mk_d = t.mk_d and a.idx in (1,5,10) order by t.rownum,a.idx "
       strDataSql = strDataSql +" "+ ")  as  k on f.ticker =k.ticker where index_name in ('TOPIX Mid400', 'TOPIX Small1', 'TOPIX Large70', 'TOPIX Core30')  order by rownum limit 30 ;"
                                                                                   
    end
    
    mydatas = ActiveRecord::Base.connection.select_all(strDataSql)
    prediction_top10 = []
    if mydatas.present? then
      si = {}
      mydatas.each do |d|
        if si["market_ticker_code"] != d["ticker"].to_s then
          if si["market_ticker_code"].present? then
            prediction_top10 << si
            si = {}
          end
          si["market_ticker_code"] = d["ticker"].to_s
          si["mkt_ticker_code"] = "EQ000000000" + d["ticker"].to_s
          si["mkt_ticker_name"] = d["eqty_name"]
          si["close_price_org"] = d["baseprice"]
        end
        si["close_price_" + d["idx"].to_s + "day"] = d["price"]
        si["mkt_date_" + d["idx"].to_s + "day"] = d["pd"]
      end
      prediction_top10 << si
      @selecttopix=rankd  #for the web select
 
      return prediction_top10
    end

  end





  def prediction_info
    url = API_SERVER_URL + '/AiTickerInfo/HistoricalData?ticker=' + params[:t]
    # url = 'http://192.168.1.100/AI_kabuapi/api/AiTickerInfo/HistoricalData?ticker=' + params[:t]
    @prediction_price = GetJsonData(url)
    @wk_stock_price = GetJsonData(API_SERVER_URL + '/TickerInfo/HistoricalData?ticker=' + params[:t])
    @wk_stock = get_wk_stock(params[:t])
    @graph = prediction_graph
  end

  def prediction_graph
    color = '#FFCC33'
    stock_datas = []
    prediction_datas = []
    stock_table_datas = []
    prediction_table_datas = []
    @table_datas = []

    @wk_stock_price.each do |data|
      stock_table_datas << [DateTime.parse(data['mkt_date']), data['close_price'].to_i.round(0), 'stock']
      stock_datas << [DateTime.parse(data['mkt_date']).to_i * 1000, data['close_price'].to_i.round(0)]
    end

    @prediction_price.each do |data|
      prediction_table_datas << [DateTime.parse(data['mkt_date']), data['close_price'].to_i.round(0), 'prediction']
      prediction_datas << [DateTime.parse(data['mkt_date']).to_i * 1000, data['close_price'].to_i.round(0),]
    end

    @table_datas = stock_table_datas
    # stock_table_datas.each do |s_table|
    #   t = []
    #   prediction_table_datas.each do |t_table|
    #     if s_table[0] == t_table[0]
    #       t = [s_table[0], s_table[1], 'both', t_table[1]]
    #       @table_datas << t
    #     else
    #       @table_datas << t_table
    #     end
    #   end
    # end

    max_index = stock_table_datas.length - 1
    prediction_table_datas.each do |t_table|
      t = []
      stock_table_datas.each_with_index do |s_table, index|
        if s_table[0] == t_table[0]
          t = [s_table[0], s_table[1], 'both', t_table[1]]
          @table_datas << t
          @table_datas.delete(s_table)
          break
        elsif max_index == index
          @table_datas << t_table
          break
        end
      end
    end


    @table_datas = @table_datas.sort { |a, b| a[0] <=> b[0] }

    LazyHighCharts::HighChart.new('graph') do |f|
    groupingUnits = [ ['week'], ['month', [1, 2, 3, 4, 6]] ]
      f.chart({
                  :marginLeft => 15,
                  :marginRight => 30,
                  :backgroundColor => '#000000',
                  :borderColor => '#FFFFFF',
                  :height => 600,
                  :borderWidth => 1

              })
      f.rangeSelector({
                # デフォルトで表示するチャートの期間を指定
                selected: 5
            })
      f.title({
                  text: "株価予測チャート"
            })
      f.yAxis({
        labels: {
          aligin: 'right',
          x: -3,
          style: { color: 'silver' },
          formatter: "function() { return this.value.toLocaleString() }".js_code,
        },
        height: '90%',
        title: {
          text: '価格'
        },
        lineWidth: 2
      })

      f.legend({
        enabled: true,
        borderWidth: 2,
        itemStyle: { color: '#fff' },
        itemHoverStyle: { color: '#000' },
        itemHiddenStyle: { color: '#E0E0E3' },
      })

      f.series({
                   name: '株価',
                   type: 'line',
                   data: stock_datas,
                   dataGrouping: {
                       units: groupingUnits
                   }
               })
      f.series({
                   name: '株価予測',
                   type: 'line',
                   data: prediction_datas,
                   dataGrouping: {
                       units: groupingUnits
                   },
               })
    end
  end

  #銘柄ごとのニュース
  def news
    #銘柄情報取得
    @wk_stock = get_wk_stock(params[:t])

    #http://39.110.206.173/kabuapi/api/News?ticker={4桁銘柄コード}
    @news = GetJsonData(API_SERVER_URL + '/News?ticker=' + params[:t])

    # #http://39.110.206.173/kabuapi/api/News?newsId={ニュースID}
    # @news = GetJsonData(API_SERVER_URL + '/News?newsId=' + params[:t])

    respond_to do |format|
      format.html
      format.js if request.xhr?
    end
  end

  def get_wk_stock(param)
      #http://39.110.206.173/kabuapi/api/TickerInfo/CompanyInfo?ticker={4桁銘柄コード}
      return GetJsonData(API_SERVER_URL + '/TickerInfo/CompanyInfo?ticker=' +param)
      # #http://39.110.206.173/kabuapi/api/TickerInfo/SecurityInfo?ticker={4桁銘柄コード}
  end

  #JSONデータ取得
  def GetJsonData(url)
    begin
      uri = URI.parse(url)
      json = Net::HTTP.get(uri)
      datas = JSON.parse(json)
      if datas == nil || datas.length == 0 then
         return ""
      end

      jsdatas = []
      datas.each_with_index do |d,idx|
        jsdatas << {}
        d.each do |key,value|
          jsdatas[idx].store(key, value)
        end
      end
      return jsdatas
    rescue Exception => e
      return ""
    end
  end
end