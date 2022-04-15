--セキュリティ・ホール
--Security Hole
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle the opponent's attacking monster to the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsLevelAbove(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	return bc:IsControler(1-tp) and bc:IsLevelBelow(8) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetAttacker()
	if chk==0 then return bc:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,bc,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local bc=Duel.GetAttacker()
	if bc:IsRelateToBattle() then
		Duel.SendtoDeck(bc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end