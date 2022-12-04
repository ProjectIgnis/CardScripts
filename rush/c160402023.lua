--ハッキング・ドラゴン
--Hacking Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon then return to the deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAttackPos() and c:IsAbleToHand() and not c:IsMaximumModeSide()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)==0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g==0 then return end
	Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	local g2=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_MZONE,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g2:Select(tp,1,1,nil)
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg,true)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end