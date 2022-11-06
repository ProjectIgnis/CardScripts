--Earthbound Fusion
--rescripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,Fusion.OnFieldMat)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.cfilter(tc)
	return tc and tc:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s.cfilter(Duel.GetFieldCard(tp,LOCATION_FZONE,0)) or s.cfilter(Duel.GetFieldCard(1-tp,LOCATION_FZONE,0))
end