--JP name
--Shamanite Shamanknight
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 3 monsters
	Xyz.AddProcedure(c,nil,3,2,nil,nil,Xyz.InfiniteMats)
	--If this card is Xyz Summoned, or if a Trap you own is banished: You can target 1 of your banished Traps; attach it to this card
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCondition(function(e)
		return e:GetHandler():IsXyzSummoned()
	end)
	e1a:SetTarget(s.attachtg)
	e1a:SetOperation(s.attachop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b:SetCode(EVENT_REMOVE)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetCondition(s.attachcon)
	c:RegisterEffect(e1b)
	--You can detach any number of materials from this card, then target 1 DARK monster in your GY or banishment with a Level equal to the number detached; Special Summon it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.DetachChoiceFromSelf(function(e,tp)
		return Duel.GetTargetGroup(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp):GetClass(Card.GetLevel)
	end))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.attachfilter(c,xyzc,tp)
	return c:IsTrap() and c:IsFaceup() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.attachfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_REMOVED,0,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_REMOVED,0,1,1,nil,c,tp)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) then
		Duel.Overlay(c,tc)
	end
end
function s.trapfilter(c,tp)
	return c:IsTrap() and c:IsFaceup() and c:IsOwner(tp)
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trapfilter,1,nil,tp)
end
function s.spfilter(c,e,tp,level)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:HasLevel() and (not level or c:IsLevel(level)) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.spfilter(chkc,e,tp,#e:GetChainData().cost_detached_materials) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	local level=#e:GetChainData().cost_detached_materials
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,level)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end