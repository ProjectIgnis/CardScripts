--スプレイム
--Splame
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--name change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter1(c,tp,code)
	return c:IsMonster() and c:IsRace(RACE_PYRO) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,c,tp,c,code)
end
function s.cfilter2(c,tp,tc,code)
	local g=Group.FromCards(c,tc)
	return c:IsMonster() and c:IsRace(RACE_PYRO) and c:IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(s.namefilter,tp,LOCATION_GRAVE,0,1,g,code)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler():GetCode()) end
end
function s.costfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PYRO) and c:IsAbleToDeckOrExtraAsCost()
end
function s.namefilter(c,code)
	return c:IsMonster() and c:IsLevelBelow(8) and not c:IsCode(code)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=c:GetCode()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
	local pg=Duel.GetMatchingGroup(s.namefilter,tp,LOCATION_GRAVE,0,nil,code)
	if #g<2 or #pg<1 then return end
	local td=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(pg),1,tp,HINTMSG_TODECK)
	Duel.HintSelection(td,true)
	if not Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST) then return end
	--Effect
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--name change
		local g2=Duel.SelectMatchingCard(tp,s.namefilter,tp,LOCATION_GRAVE,0,1,1,nil,code)
		if #g2>0 then
			Duel.HintSelection(g2,true)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			e1:SetValue(g2:GetFirst():GetCode())
			c:RegisterEffect(e1)
		end
	end
end
function s.rescon(pg)
	return function(sg,e,tp,mg)
		local check=pg:IsExists(aux.TRUE,1,sg)
		return check,not check
	end
end