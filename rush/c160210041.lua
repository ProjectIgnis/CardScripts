--花牙封じのエトランゼ
--Etraynze the Shadow Flower Restricter
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Etraynze the Shadow Flower Ninja" in the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(160005029)
	c:RegisterEffect(e1)
	--name change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={160005029,CARD_FUSION} --Etraynze the Shadow Flower Ninja
function s.cfilter(c,tp,code)
	return c:IsMonster() and c:IsRace(RACE_PLANT) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(s.namefilter,tp,LOCATION_GRAVE,0,1,g,code)
end
function s.namefilter(c,code)
	return c:IsMonster() and c:IsRace(RACE_PLANT) and not c:IsCode(code)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler():GetCode()) end
end
function s.setfilter(c)
	return c:IsCode(CARD_FUSION) and c:IsSSetable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=c:GetCode()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp,code)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)~=1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g2=Duel.SelectMatchingCard(tp,s.namefilter,tp,LOCATION_GRAVE,0,1,1,nil,code)
	if #g2>0 then
		Duel.HintSelection(g2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(g2:GetFirst():GetCode())
		c:RegisterEffect(e1)
		local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,nil)
		if #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g3:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
		end
	end
end