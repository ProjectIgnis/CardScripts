--魔轟神獣ルビィラーダ
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCost(s.cost)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={0x35}
function s.cfilter(c)
	return c:IsSetCard(0x35) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
