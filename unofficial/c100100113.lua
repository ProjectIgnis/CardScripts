--Ｓｐ－スピード・ジャマー
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.con)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	return tc1 and tc2 and tc1:GetCounter(0x91)>1 and tc2:GetCounter(0x91)>5
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)	
	local tc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	if not tc then return end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	tc:RemoveCounter(tp,0x91,6,REASON_COST)	
end
