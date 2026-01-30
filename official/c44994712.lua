--捕食植物ロンギネフィラ
--Predaplant Longinephila
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Predap" card from your Deck to your hand
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.thtg)
	e1a:SetOperation(s.thop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Activate 1 of the following effects (Place Predator Counter, Set "Polymerization" from GY or banishment)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PREDAP}
s.listed_names={CARD_POLYMERIZATION,id}
s.counter_place_list={COUNTER_PREDATOR}
function s.predapthfilter(c)
	return c:IsSetCard(SET_PREDAP) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.predapthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.predapthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.predctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_PREDATOR,1)
end
function s.polysetfilter(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsFaceup() and c:IsSSetable()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.predctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.polysetfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_COUNTER)	
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,COUNTER_PREDATOR)
	elseif op==2 then
		e:SetCategory(CATEGORY_SET)
		Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Place 1 Predator Counter on 1 monster on the field and make it Level 1 so long as it has a Predator Counter if it is Level 2 or higher
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		local tc=Duel.SelectMatchingCard(tp,s.predctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		if not tc then return end
		Duel.HintSelection(tc)
		if tc:AddCounter(COUNTER_PREDATOR,1) and tc:IsLevelAbove(2) then
			--It becomes Level 1 as long as it has a Predator Counter
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetCondition(function(e) return e:GetHandler():HasCounter(COUNTER_PREDATOR) end)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		--Set 1 "Polymerization" from your GY or banishment
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.polysetfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.SSet(tp,sg)
		end
	end
end