--継承の魔戦士
--Magical Warrior of Heritage
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cfilter(c,tp,code)
	return c:IsRace(RACE_SPELLCASTER|RACE_WARRIOR) and (c:IsAttack(2600) or c:IsDefense(2600)) and not c:IsCode(code)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler():GetCode()) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler():GetCode()) end
end
function s.cfilter2(c,code)
	return c:IsRace(RACE_SPELLCASTER|RACE_WARRIOR) and (c:IsAttack(2600) or c:IsDefense(2600)) and not c:IsCode(code)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,tp)
	local td=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SELECT)
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler():GetCode())
	if #g>0 then
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(g:GetFirst():GetCode())
		c:RegisterEffect(e1)
	end
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,sg,e:GetHandler():GetCode())
end