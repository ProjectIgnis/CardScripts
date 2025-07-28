--プリンセス・コロン
--Princess Cologne
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--Special Summon 1 "Box of Friends" from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.boxsptg)
	e1:SetOperation(s.boxspop)
	c:RegisterEffect(e1)
	--If you control another monster, your opponent's monsters cannot target this card for attacks, also your opponent cannot target this card with card effects
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2a:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCondition(function(e) return Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler()) end)
	e2a:SetValue(aux.imval1)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2b:SetValue(aux.tgoval)
	c:RegisterEffect(e2b)
	--Special Summon 1 Normal Monster from your Deck or GY in Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.normalspcon)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.normalsptg)
	e3:SetOperation(s.normalspop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BOX_OF_FRIENDS}
function s.boxspfilter(c,e,tp)
	return c:IsCode(CARD_BOX_OF_FRIENDS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.boxsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.boxspfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.boxspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.boxspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.boxspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.normalspconfilter(c,tp)
	return c:IsPreviousTypeOnField(TYPE_NORMAL) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsType(TYPE_NORMAL)
end
function s.normalspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.normalspconfilter,1,nil,tp)
end
function s.normalspfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.normalsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.normalspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.normalspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.normalspfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end