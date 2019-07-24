--High and Low
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsControler(tp) and d:IsFaceup() and Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local ct=0
	while ct<3 and Duel.IsPlayerCanDiscardDeck(tp,1) and (ct==0 or Duel.SelectYesNo(tp,aux.Stringid(id,0))) do
		local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
		if tc:IsType(TYPE_MONSTER) then
			local ca=tc:GetAttack()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ca)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			d:RegisterEffect(e1)
		end
		if d:GetAttack() > a:GetAttack() then
			Duel.BreakEffect()
			Duel.Destroy(d,REASON_EFFECT)
			if not d:IsLocation(LOCATION_MZONE) then
				return
			end
		end
		ct=ct+1
	end
end
