--御巫の水舞踏
--Arabesque of the Mikanko
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Prevent destruction by effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Special Summon 1 "Mikanko" monster, re-equip and return equip target to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x28a}
function s.spfilter(c,e,tp,code)
	return c:IsSetCard(0x28a) and not c:IsOriginalCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and e:GetHandler():CheckEquipTarget(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqc=e:GetHandler():GetEquipTarget()
	if chk==0 then return eqc and eqc:IsAbleToHand() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,eqc:GetOriginalCode()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eqc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,eqc:GetOriginalCode())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local eq=g:GetFirst()
		if Duel.Equip(tp,c,eq) and eqc:IsFaceup() and eqc:IsAbleToHand() then
			Duel.BreakEffect()
			Duel.SendtoHand(eqc,nil,REASON_EFFECT)
		end
	end
end