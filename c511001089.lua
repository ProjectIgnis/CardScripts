--Wonder Recipe
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={511001086}
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(511001086) and c:GetOverlayCount()>0
end
function s.filter(c,e,sp)
	return c:IsSetCard(0x1512) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_SZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local fc=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
	if fc:GetOverlayCount()<ft then ft=fc:GetOverlayCount() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(Group.FromCards(fc))
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		Duel.Damage(1-tp,#g*300,REASON_EFFECT)
	end
end
