--終焔の絶望
--Doomblaze Despair
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle the opponent's attacking monster to the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local atkr=Duel.GetAttacker()
	local defr=Duel.GetAttackTarget()
	return atkr and defr and atkr:IsControler(1-tp) and atkr:IsLevelBelow(8) and defr:IsControler(tp) and defr:IsType(TYPE_MAXIMUM)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,600) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetAttacker()
	if chk==0 then return bc:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,bc,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.PayLPCost(tp,600)
	--Effect
	local bc=Duel.GetAttacker()
	if bc:IsRelateToBattle() then
		Duel.SendtoDeck(bc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsMaximumMode),tp,LOCATION_MZONE,0,nil)
		if ct>0 then
			Duel.Damage(1-tp,600,REASON_EFFECT)
		end
	end
end
