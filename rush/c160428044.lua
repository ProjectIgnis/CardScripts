--サイキック・オメガブラスト
--Psychic Omega Blast
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	 return Duel.GetMatchingGroupCountRush(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>=2
end
function s.costfilter(c)
	return c:IsRace(RACE_PSYCHIC) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		--Effect
		local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
		if #dg>0 then
			local res=nil
			local tc=dg:GetMinGroup(Card.GetAttack)
			if #tc>1 then --make the player select if more than 1
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local sg=tc:Select(tp,1,1,nil)
				Duel.HintSelection(sg,true)
				if Duel.Destroy(sg,REASON_EFFECT)>0 then res=sg:GetFirst():GetTextAttack() end
			else   --otherwise, directly destroy it
				if Duel.Destroy(tc,REASON_EFFECT)>0 then res=tc:GetFirst():GetTextAttack() end
			end
			if res and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_OMEGAPSYCHIC),tp,LOCATION_MZONE,0,1,nil) then
				Duel.Damage(1-tp,res,REASON_EFFECT)
			end
		end
	end
end