--Live☆Twin キスキル
--Live☆Twin Kisikil
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--If normal summoned, special summon 1 "Lilla" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Same as above but if special summoned
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Each time opponent declares an attack, gain 500 LP
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
end
	--Lists "Lilla" archetype
s.listed_series={0x24d}
	--Specifically lists itself
s.listed_names={id}
	--Check if no other monsters
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
	--Check for "Lilla" monster
function s.filter(c,e,tp)
	return c:IsSetCard(0x24d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
	--Special summon 1 "Lilla" monster from hand/deck
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
	--Each time opponent declares an attack, gain 500 LP
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetAttacker():IsControler(1-tp) then
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
