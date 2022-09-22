--ネオ・プランディッシュ
--Neo Plandish
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make itself unable to be destroyed by opponent's traps
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.DisableShuffleCheck()
	local g=Duel.GetMatchingGroup(function(c)return c:GetSequence()<1 end,tp,LOCATION_DECK,0,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():GetFirst()
	--Effect
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--Cannot be destroyed by opponent's trap
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3012)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if ct:IsRace(RACE_PLANT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			e2:SetValue(700)
			c:RegisterEffectRush(e2)
		end
	end
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end