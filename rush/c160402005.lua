--機動砦のバスキュール
--Bascule the Moving Fortress

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Change its battle positions, then special summon 1 EARTH normal monster from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
	--If normal summoned this turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
	--Check for EARTH normal monster
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
	--Change its battle positions, then special summon 1 EARTH normal monster from GY
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.DiscardDeck(tp,3,REASON_COST)==3 then return end
	if not c:IsRelateToEffect(e) then return end
	if Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK) then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
			Duel.HintSelection(Group.FromCards(sg))
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
