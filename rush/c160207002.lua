--超魔軌道マグナム・オーバーロード
--Supreme Fullsteam Magnum Overlord
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddMaximumAtkHandler()
end
s.MaximumAttack=3500
function s.filter1(c)
	return c:IsCode(160207001)
end
function s.filter2(c)
	return c:IsCode(160207003)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffectRush(e1)
			if c:IsMaximumMode() then
				--Cannot be destroyed by opponent's card effects
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(3060)
				e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
				e2:SetValue(aux.indoval)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				c:AddCenterToSideEffectHandler(e2)
				c:RegisterEffectRush(e2)
			end
		end
	end
end