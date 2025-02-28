--一騎討ち
--One-on-One Fight
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local turn_player=Duel.GetTurnPlayer()
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.CanAttack),turn_player,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsFaceup,turn_player,0,LOCATION_MZONE,1,nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local turn_player=Duel.GetTurnPlayer()
	local g1=Duel.GetMatchingGroup(aux.FaceupFilter(Card.CanAttack),turn_player,LOCATION_MZONE,0,nil)
	if #g1==0 then return end
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,turn_player,0,LOCATION_MZONE,nil)
	if #g2==0 then return end
	Duel.Hint(HINT_SELECTMSG,turn_player,HINTMSG_SELF)
	local bc1=(g1:GetMaxGroup(Card.GetAttack):Select(turn_player,1,1,nil)):GetFirst()
	Duel.HintSelection(bc1)
	Duel.Hint(HINT_SELECTMSG,1-turn_player,HINTMSG_SELF)
	local bc2=(g2:GetMaxGroup(Card.GetAttack):Select(1-turn_player,1,1,nil)):GetFirst()
	Duel.HintSelection(bc2)
	Duel.CalculateDamage(bc1,bc2)
end