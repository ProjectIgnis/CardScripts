--メガジョインテック・フォートレックス［Ｒ］
--Mega Jointech Fortrex [R]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 3 monsters from the GYs to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Right"
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,100)
end
function s.ogfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:GetOriginalLevel()>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local dg1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,0,LOCATION_GRAVE,3,3,nil)
	if #dg1==0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
	local dg2=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil)
	if #dg2==0 then return end
	dg1:Merge(dg2)
	Duel.HintSelection(dg1,true)
	Duel.SendtoDeck(dg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	--Effect
	local c=e:GetHandler()
	local og=Duel.GetOperatedGroup():Filter(s.ogfilter,nil)
	if #og>0 and c:IsMaximumMode() then
		local ct=og:GetSum(Card.GetOriginalLevel)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end