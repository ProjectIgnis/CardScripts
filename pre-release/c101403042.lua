--六花深聖ストレナエ
--Rikka Empress Strenna
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 6 Plant monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),6,2)
	--You can detach 2 materials from this card; Special Summon 1 Plant Xyz Monster from your Extra Deck in Defense Position, except "Rikka Empress Strenna", then if you Special Summoned a "Rikka" monster, you can attach 1 "Rikka" monster from your Deck to it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.DetachFromSelf(2))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If a monster(s) is Tributed: You can Set 1 "Rikka" Trap from your Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_RIKKA}
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsXyzMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		 and not c:IsCode(id) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.attachfilter(c,xc,e,tp)
	return c:IsSetCard(SET_RIKKA) and c:IsMonster()
		and not c:IsImmuneToEffect(e) and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not xc or Duel.SpecialSummon(xc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==0 or not xc:IsSetCard(SET_RIKKA) then return end
	local mg=Duel.GetMatchingGroup(s.attachfilter,tp,LOCATION_DECK,0,nil,xc,e,tp)
	if #mg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mc=mg:Select(tp,1,1,nil)
	if #mc>0 then
		Duel.BreakEffect()
		Duel.Overlay(xc,mc)
	end
end
function s.setconfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) or (c:IsMonsterCard() and not c:IsPreviousLocation(LOCATION_SZONE))
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.setconfilter,1,nil)
end
function s.setfilter(c)
	return c:IsSetCard(SET_RIKKA) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end