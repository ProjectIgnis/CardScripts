--ナチュル・ハイドランジー
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_series={0x2a}
function s.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsSetCard(0x2a) and re:IsActiveType(TYPE_MONSTER)
		and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
