--ダイスキー・リリス
--Dice Key Lilith
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--dice
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)<1 then return end
	--Effect
	local d=Duel.TossDice(tp,1)
	if d==1 or d==2 or d==3 then
		c:AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB_FAIRY)
	else
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_FAIRY) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsRace(RACE_FAIRY) and c:IsLevelAbove(7) and c:IsSummonableCard()
end