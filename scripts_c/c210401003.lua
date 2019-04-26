--Survivor - Megalosaurus
function c210401003.initial_effect(c)
	c:EnableReviveLimit()
	--Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c210401003.spcon)
	e2:SetOperation(c210401003.spop)
	c:RegisterEffect(e2)
end
function c210401003.spfilter(c)
	if not c:IsSetCard(0xf18) or not c:IsAbleToRemoveAsCost() then return false end
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741) then
		return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
	else
		return c:IsLocation(LOCATION_GRAVE)
	end
end
function c210401003.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.IsPlayerAffectedByEffect(tp,69832741))
		and Duel.IsExistingMatchingCard(c210401003.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,nil)
end
function c210401003.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c210401003.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end