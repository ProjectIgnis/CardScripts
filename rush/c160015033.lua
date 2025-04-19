--絶望狂魔デッド・エンド
--Dead End the Mad Fiend of Despair
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster the opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.attfilter(c,tp)
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,5,c,c:GetAttribute())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	--Effect
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		dg:AddMaximumCheck()
		Duel.HintSelection(dg,true)
		local ct=Duel.Destroy(dg,REASON_EFFECT)
		if ct>0 then
			local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,nil,e,tp)
			if #g2>0 and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
				if #sg>0 then
					Duel.BreakEffect()
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
