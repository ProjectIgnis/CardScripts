--ディープスペース・インパクト
--Deep Space Impact
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Increase the ATK of 1 Warrior you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={160211020,CARD_FUSION} --Deep Warning Fusion
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.tdfilter(c)
	return ((c:IsMonster() and c:IsRace(RACE_CYBERSE)) or (c:IsCode(160211020,CARD_FUSION))) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tdg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,6,nil)
	Duel.HintSelection(tdg,true)
	if Duel.SendtoDeck(tdg,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 then
			Duel.SortDecktop(tp,tp,ct)
		end
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_FUSION),tp,LOCATION_MZONE,0,1,nil) then return end
		local sg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsMonster),tp,0,LOCATION_MZONE,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsMonster),tp,0,LOCATION_MZONE,1,1,nil)
			if #tg>0 then
				tg=tg:AddMaximumCheck()
				Duel.HintSelection(tg,true)
				Duel.Destroy(tg,REASON_EFFECT)
			end
		end
	end
end