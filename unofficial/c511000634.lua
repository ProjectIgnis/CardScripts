--困惑のマスク
--Mask of Perplexity
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(function(e,tp,eg) return eg:GetFirst():IsControler(tp) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ac=Duel.GetAttacker()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc~=ac end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,ac) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,ac)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and ac and ac:IsRelateToBattle()
		and ac:CanAttack() and not ac:IsImmuneToEffect(e) then
		--Allow the player to attack their own monster for this battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SELF_ATTACK)
		e1:SetTargetRange(1,1)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
		Duel.ChangeAttackTarget(tc)
	end
end