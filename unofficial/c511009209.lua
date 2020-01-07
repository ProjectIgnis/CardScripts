--Robocircus
--Scripted by eclair11
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--sp summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.filter(c,e,pl)
	return c:IsSetCard(0x85) and c:IsCanBeSpecialSummoned(e,0,pl,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local pl=eg:GetFirst():GetSummonPlayer()
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsRace(RACE_MACHINE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,pl,LOCATION_HAND,0,1,nil,e,pl) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,pl,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local pl=eg:GetFirst():GetSummonPlayer()
	if Duel.GetLocationCount(pl,LOCATION_MZONE)<=0 or not Duel.SelectEffectYesNo(pl,e:GetHandler()) then return end
	Duel.Hint(HINT_SELECTMSG,pl,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(pl,s.filter,pl,LOCATION_HAND,0,1,1,nil,e,pl)
	if #g>0 then
		Duel.SpecialSummon(g,0,pl,pl,false,false,POS_FACEUP)
	end
end