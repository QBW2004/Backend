// Consume actual backend/isolated-MySQL output with the real DaBaiTu server objects.
// No server process, external connection, or production database is started here.
#include "ServerCardPhenix/ServerRun.h"
#include "ServerCardPhenix/RabbitRulesJson.h"
#include <chrono>
#include <fstream>
#include <functional>
#include <memory>

static int checks = 0;
static void Check(bool value, const char* name)
{
    ++checks;
    if (!value) throw std::runtime_error(name);
}
static UInt32 Num(const Rabbit::Object& obj, const std::string& key) { return obj->getValue<UInt32>(key); }
static void ReadBlob(CLOB& blob, const std::function<void(BinaryReader&)>& read)
{
    CLOBInputStream input(blob); BinaryReader reader(input, BinaryReader::NETWORK_BYTE_ORDER); read(reader);
}
static void Rules(UInt16 index, const std::string& json)
{
    CLOB blob; CLOBOutputStream output(blob); BinaryWriter writer(output, BinaryWriter::NETWORK_BYTE_ORDER);
    writer << index << (UInt16)json.size(); writer.writeRaw(json.data(), json.size());
    ReadBlob(blob, [&](BinaryReader& reader) { ServerRun::ReceiveRabbitRules(reader, (UInt16)(json.size() + 4)); });
}
static void SameLeaves(const Rabbit::Object& expected, const Rabbit::Object& actual)
{
    std::vector<std::string> names; expected->getNames(names);
    for (const auto& name : names)
    {
        if (expected->isObject(name)) SameLeaves(expected->getObject(name), actual->getObject(name));
        else if (expected->isArray(name)) {
            auto a=expected->getArray(name), b=actual->getArray(name);
            Check(b && a->size()==b->size(), "runtime array size");
            for(size_t i=0;i<a->size();++i) Check(a->get(i).toString()==b->get(i).toString(), "runtime array value");
        }
        else Check(actual->has(name) && expected->get(name).toString()==actual->get(name).toString(), "runtime gameplay field");
    }
}
int main(int argc, char** argv)
{
    _set_error_mode(_OUT_TO_STDERR); SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);
    auto start=std::chrono::steady_clock::now();
    try {
        if(argc!=2) throw std::runtime_error("Expected isolated backend fixture file");
        std::ifstream input(argv[1]); if(!input)throw std::runtime_error("Backend fixture missing");
        Poco::JSON::Parser parser; auto root=parser.parse(input).extract<Rabbit::Object>();
        auto rows=root->getArray("tables"); Check(rows && rows->size()==2, "two real backend table snapshots");
        ts_RoomInfo room={}; room.num=2;room.betMin=1;room.betMax=100;room.oneCoinScore=100;
        ts_TablePara defaults[2]={};
        ServerRun::roomInfo=&room;ServerRun::roomMax=1;ServerRun::tablePara=defaults;
        std::unique_ptr<ServerRun> first(new ServerRun(0)),second(new ServerRun(1));
        first->roomID=second->roomID=0;
        first->pAlg->rabbitStatePath.clear();second->pAlg->rabbitStatePath.clear();
        ServerRun::gameTable={first.get(),second.get()};ServerRun::tableMax=2;
        CLOB extended;CLOBOutputStream output(extended);BinaryWriter writer(output,BinaryWriter::NETWORK_BYTE_ORDER);
        writer<<(UInt16)2;
        for(UInt16 i=0;i<2;++i){
            auto table=rows->getObject(i)->getObject("table");
            ts_RoomTableConfig config={}; config.ID=i+1;config.GameID=55;config.TableIndex=i;
            std::string name=table->getValue<std::string>("tableName");strncpy(config.TableName,name.c_str(),sizeof(config.TableName)-1);
            config.BetMin=Num(table,"minBet");config.BetMax=Num(table,"maxBet");config.OneCoinScore=Num(table,"coinSc");config.CoinsNeed=Num(table,"coinNeed");
            config.Enabled=(UInt8)Num(table,"enabled");config.IdleFireTimeoutSec=Num(table,"idleFireTimeoutSec")*60;
            config.IdleFireKickEnabled=1;config.MaxSeats=(UInt16)Num(table,"maxSeats");config.GunPowerStep=(UInt16)(Num(table,"scoreSwitch")*10);
            writer.writeRaw((char*)&config,sizeof(config));
        }
        writer<<(UInt16)32;
        for(UInt16 i=0;i<2;++i){
            auto table=rows->getObject(i)->getObject("table"),payout=table->getObject("payout");
            for(int h=0;h<16;++h){
                ts_CardPayoutProfile p={};p.ID=i*16+h+1;p.GameID=55;p.TableId=i;
                p.HandType=h<13?h:201+h-13;
                p.ProbabilityBasis=h<13?Num(payout,"p"+std::to_string(h)):Num(table,"jk"+std::to_string(h-12));
                p.Enabled=h<13?Num(payout,"e"+std::to_string(h)):Num(table,"jokerOn");
                writer.writeRaw((char*)&p,sizeof(p));
            }
        }
        writer<<(UInt16)2;
        for(UInt16 i=0;i<2;++i){auto t=rows->getObject(i)->getObject("table");writer<<i<<Num(t,"exCoin")<<Num(t,"scoreSwitch")<<Num(t,"gameMo")<<(UInt32)(Num(t,"maxBet")*10);}
        ReadBlob(extended,[](BinaryReader& reader){ServerRun::ServerCenterRecvExtendedPara(reader);});
        for(UInt16 i=0;i<2;++i){
            auto row=rows->getObject(i),t=row->getObject("table"),expected=row->getObject("rules");auto table=ServerRun::gameTable[i];
            Check(table->CardBetMin()==Num(t,"minBet"),"per-table minimum adopted");Check(table->CardBetMax()==Num(t,"maxBet"),"per-table maximum adopted");
            Check(table->CardOneCoinScore()==Num(t,"coinSc"),"per-table score per diamond adopted");Check(table->mCardPara.coinsNeed==Num(t,"coinNeed"),"per-table minimum bring-in adopted");
            Check(table->CardOneExchangeCoin()==Num(t,"exCoin"),"preserved exchange parameter adopted");Check(table->CardScoreSwitch()==Num(t,"scoreSwitch"),"per-table increment adopted");
            Check(table->CardGameMo()==Num(t,"gameMo"),"preserved game mode adopted");Check(table->CardMaxBetUnits()==Num(t,"maxBet")*10,"maximum units adopted");
            Check(table->IsTableEnabled()==(Num(t,"enabled")!=0),"table enable toggle adopted");
            const auto& snapshot=ServerRun::s_roomTableConfigs[i];
            Check(snapshot.IdleFireTimeoutSec==Num(t,"idleFireTimeoutSec")*60 && snapshot.IdleFireKickEnabled==1,"idle timeout and toggle adopted");
            Check(RoomTableConfigName(snapshot)==t->getValue<std::string>("tableName"),"table name adopted");
            Check(snapshot.GunPowerStep==Num(t,"scoreSwitch")*10,"client step units adopted");
            UInt32 probability[CARDS_TYPE_MAX],multipliers[CARDS_TYPE_MAX],jokers[3];
            Check(ServerRun::GetCardPayoutSnapshot(i,probability,multipliers),"per-table payout snapshot enabled");
            for(int h=0;h<CARDS_TYPE_MAX;++h){auto p=t->getObject("payout");Check(probability[h]==(Num(p,"e"+std::to_string(h))?Num(p,"p"+std::to_string(h)):0),"individual payout enabled/probability adopted");Check(multipliers[h]==0xFFFFFFFF,"fixed payout values remain server controlled");}
            Check(ServerRun::GetJokerProbSnapshot(i,jokers)==(Num(t,"jokerOn")!=0),"joker switch adopted");
            for(int j=0;j<3;++j)Check(jokers[j]==Num(t,"jk"+std::to_string(j+1)),"joker count weight adopted");
            CLOB difficulty;CLOBOutputStream ds(difficulty);BinaryWriter dw(ds,BinaryWriter::NETWORK_BYTE_ORDER);
            dw<<i;std::string dif=t->getValue<std::string>("cardDif");for(char c:dif)dw<<(UInt8)(c-'0');dw<<(UInt8)Num(t,"hypeType");
            ReadBlob(difficulty,[](BinaryReader& r){ServerRun::ServerCenterTableSetting(r);});
            for(int d=0;d<16;++d)Check(table->pAlg->gs_run.e_dif[d]==dif[d]-'0',"difficulty digit adopted");
            Check(table->pAlg->gs_run.hype_type==Num(t,"hypeType"),"hype type adopted");
            Rules(i,Rabbit::Stringify(expected));table->ApplyRabbitRules();SameLeaves(expected,Rabbit::WriteConfig(table->pAlg->rabbitConfig));
            auto& alg=*table->pAlg;auto& c=alg.rabbitConfig;
            alg.gs_acc_cur.bet=10;alg.gs_alg.twice_type=e_4_OF_A_KIND_L;alg.RabbitSettleHand();Check(alg.gs_acc_cur.win==10*c.smallFourMultiplier,"small-four actual payout uses independent multiplier");
            alg.gs_alg.twice_type=e_4_OF_A_KIND_B;UInt8 cards[5]={10,23,36,49,3};std::copy(cards,cards+5,alg.gs_alg.twice_cards);alg.gs_alg.F_K_B_true_mag=4;alg.RabbitSettleHand();
            Check(alg.gs_acc_cur.win==10*c.authenticBase*(c.authenticEnabled?4:1),"authentic base and enabled switch affect actual payout");
            alg.gs_alg.twice_type=e_5_OF_A_KIND;bool win=false,miss=false;alg.rabbitRandom.seed(49);
            for(int n=0;n<100;++n){alg.rabbitForcedFive=false;alg.RabbitSettleHand();if(c.fiveEnabled){Check(alg.gs_acc_cur.win==10*c.fiveBase*alg.gs_alg.F_O_K_dou_mag,"five actual payout matches selected multiplier");win|=alg.gs_alg.F_O_K_dou_mag==c.fiveSuccess;miss|=alg.gs_alg.F_O_K_dou_mag==c.fiveMiss;}else Check(alg.gs_acc_cur.win==10*c.fiveBase,"disabled five uses base payout only");}
            if(c.fiveEnabled)Check(win&&miss,"configured natural five probability produces both outcomes");
            Rabbit::State state;std::mt19937 random(7);state.Begin(c,1000,false,random);
            Check(state.pool==(c.streakEnabled?c.initialPool+1000*c.contribution/10000:c.initialPool),"initial pool and contribution adopted on first hand");
            if(c.streakEnabled)Check(state.nextCount==2||state.nextCount==4||state.nextCount==6,"streak count draws configured tiers");
            else Check(!state.planned&&state.remaining==0&&state.window==0,"disabled streak does not plan award");
        }
        auto before=Rabbit::Stringify(Rabbit::WriteConfig(second->pAlg->rabbitConfig));
        auto changed=rows->getObject(0)->getObject("rules");changed->set("smallFourMultiplier",99);Rules(0,Rabbit::Stringify(changed));first->ApplyRabbitRules();second->ApplyRabbitRules();
        Check(first->pAlg->rabbitConfig.smallFourMultiplier==99 && Rabbit::Stringify(Rabbit::WriteConfig(second->pAlg->rabbitConfig))==before,"hot update of table A does not change B");
        Rules(0,"{}");first->ApplyRabbitRules();Check(first->pAlg->rabbitConfig.smallFourMultiplier==99,"invalid rule frame keeps prior valid configuration");
        ServerRun::gameTable.clear();ServerRun::tableMax=0;
        auto ms=std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now()-start).count();
        std::cout<<"PASS "<<checks<<" actual DaBaiTu parameter/application/settlement checks in "<<ms<<"ms\n";
        return 0;
    }catch(const std::exception& error){std::cerr<<error.what()<<" at check "<<checks<<std::endl;return 1;}
}
