--Ａｉラブ融合
--A.I. Love Fusion
--Scripted by ahtelel, anime version by Larry126
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),nil,s.fextra)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x135}
function s.chkfilter(c,tp,fc)
	return c:IsSetCard(0x135,fc,SUMMON_TYPE_FUSION,tp) and c:IsControler(tp)
end
function s.fcheck(tp,sg,fc,mg)
	if sg:IsExists(Card.IsControler,1,nil,1-tp) then 
		return sg:IsExists(s.chkfilter,1,nil,tp,fc) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(Card.IsSetCard,1,nil,0x135,nil,SUMMON_TYPE_FUSION,tp) then
		local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsLinkMonster,Card.IsAbleToGrave),tp,0,LOCATION_MZONE,nil)
		if g and #g>0 then
			return g,s.fcheck
		end
	end
	return nil
end