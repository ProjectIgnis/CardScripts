--クリアー・バイス・ドラゴン
--Clear Vice Dragon
local s,id=GetID()
function s.initial_effect(c)
	--You are unaffected by the effects of "Clear World"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CLEAR_WORLD_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	c:RegisterEffect(e1)
	--If this card attacks an opponent's monster, the ATK of this card becomes twice the ATK of the attack target, during damage calculation only
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(function(e,c) return Duel.GetAttackTarget():GetAttack()*2 end)
	c:RegisterEffect(e2)
	--If this card would be destroyed by an opponent's card effect, you can discard 1 card instead
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.reptg)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_CLEAR_WORLD}
function s.atkcon(e)
	local bc=Duel.GetAttackTarget()
	return Duel.IsPhase(PHASE_DAMAGE_CAL) and e:GetHandler()==Duel.GetAttacker() and bc and bc:IsControler(1-e:GetHandlerPlayer())
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:IsReasonPlayer(1-tp)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96) and Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)>0
end