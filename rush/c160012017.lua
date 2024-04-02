--闇眼の破星猫
-- Dark-Eyes Breakstar Cat
local s,id=GetID()
function s.initial_effect(c)
	--mill 1 for piercing
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP() and e:GetHandler():CanGetPiercingRush()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,2,REASON_COST)==2 then
		--Effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Piercing
			c:AddPiercing(RESETS_STANDARD_PHASE_END)
			local desg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
			if #desg>0 and c:IsStatus(STATUS_SPSUMMON_TURN) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local tg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,1,1,nil)
				if #tg>0 then
					tg=tg:AddMaximumCheck()
					Duel.HintSelection(tg,true)
					Duel.Destroy(tg,REASON_EFFECT)
				end
			end
		end
	end
end
function s.desfilter(c)
	return (c:IsLevel(7) or c:IsLevel(8)) and c:IsFaceup()
end