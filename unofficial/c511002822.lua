--天魔合唱
--Prayer to the Evil Spirits
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.InHandMat,s.fextra,nil,nil,nil,2)
	c:RegisterEffect(e1)
end
s.listed_series={0xef,0x154a}
function s.checkextra(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==1
		and sg:FilterCount(Card.IsAngel,nil,fc,SUMMON_TYPE_FUSION,tp)==2
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil),s.checkextra
end