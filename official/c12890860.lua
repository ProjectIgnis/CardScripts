--Japanese name
--Denial Deity Dotan
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 LIGHT monster + 2 monsters, except on the field or in the GY
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,s.matfilter,2)
	--This Fusion Summoned card cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--As long as no monsters on your field or GY share an original name with any monster on your opponent's field or GY, monsters you control cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indescon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Banish 1 monster on your opponent's field or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.rmvcost)
	e3:SetTarget(s.rmvtg)
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)
end
function s.matfilter(c,fc,sumtype,tp)
	return not c:IsLocation(LOCATION_GRAVE|LOCATION_ONFIELD) 
end
function s.indesconfilter(c,tp)
	return c:IsFaceup() and c:IsMonster()
		and Duel.IsExistingMatchingCard(s.samenamefilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,c:GetOriginalCodeRule())
end
function s.samenamefilter(c,code)
	return c:IsFaceup() and c:IsMonster() and c:IsOriginalCodeRule(code)
end
function s.indescon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(s.indesconfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp)
end
function s.costfilter(c,tp)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.samenamefilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,c:GetOriginalCodeRule())
end
function s.rmvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.rmvfilter(c)
	return c:IsAbleToRemove() and c:IsMonster()
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.rmvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmvfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmvfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end