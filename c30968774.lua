--スワップリースト
--Swap Cleric
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r & REASON_LINK == REASON_LINK
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc=e:GetHandler():GetReasonCard()
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and sc:IsAttackAbove(500) and sc:IsType(TYPE_LINK) end
	Duel.SetTargetCard(sc)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,sc,1,LOCATION_MZONE,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=Duel.GetFirstTarget()
	if not sc:IsFaceup() or sc:GetAttack()<500 or not sc:IsRelateToEffect(e) or not sc:IsType(TYPE_LINK) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc:RegisterEffect(e1)
	if not sc:IsImmuneToEffect(e1) and not sc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		Duel.BreakEffect()
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
