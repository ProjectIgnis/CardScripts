--天賦の魔導士クロウリー
--Crowley, the Gifted of Magistus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this face-up card is used as Fusion Material, its name can be treated as "Aleister the Invoker"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(86120751)
	e1:SetOperation(function(scard,sumtype,tp) return (sumtype&MATERIAL_FUSION)>0 or (sumtype&SUMMON_TYPE_FUSION)>0 end)
	c:RegisterEffect(e1)
	--Special Summon this card when it is added to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
	--Fusion Summon 1 "Magistus" or "Invoked" Fusion Monster from your Extra Deck, using monsters from your hand or field as material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(Fusion.SummonEffTG(aux.FilterBoolFunction(Card.IsSetCard,{SET_MAGISTUS,SET_INVOKED})))
	e3:SetOperation(Fusion.SummonEffOP(aux.FilterBoolFunction(Card.IsSetCard,{SET_MAGISTUS,SET_INVOKED})))
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.listed_names={86120751} --"Aleister the Invoker"
s.listed_series={SET_MAGISTUS,SET_INVOKED}
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end