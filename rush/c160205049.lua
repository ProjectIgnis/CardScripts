--破滅の竜魔導士
--Destroyer of Dragon Sorcerers
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of your monsters unable to be destroyed by opponent's Trap card effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER+RACE_DRAGON) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function s.sfilter(c)
	return c:IsCode(160301013) and c:IsSSetable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.HintSelection(g)
	if g and Duel.SendtoDeck(g,nil,4,REASON_COST)>0 then
		--Effect
		local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then 
			Duel.HintSelection(tc,true)
			--Cannot be destroyed by opponent's trap
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3012)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			--Set cards
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
			if ft>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				Duel.HintSelection(tg)
				Duel.SSet(tp,tg)
			end
		end
	end
end
function s.efilter(e,re,rp)
	return re:IsActiveType(TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
