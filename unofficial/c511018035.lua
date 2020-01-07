--Ｇゴーレム・クリスタルハート
--G Golem Crystal Heart
local cid, id = GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cid.sptarget)
	e1:SetOperation(cid.spoperation)
	c:RegisterEffect(e1)
	--increase attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(cid.uatarget)
	e2:SetValue(cid.uavalue)
	c:RegisterEffect(e2)
	--extra attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.eacondition)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(cid.eatarget)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function cid.spfilter(c,e,tp,ec)
	local zone=ec:GetToBeLinkedZone(c,tp,true)
	return c:IsLinkMonster() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function cid.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and cid.spfilter(chkc,e,tp,e:GetHandler()) end
	if chk==0 then return Duel.IsExistingTarget(cid.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cid.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function cid.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			local zone=c:GetToBeLinkedZone(tc,tp,true)
			if zone>0 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
			end
		end
		Duel.BreakEffect()
		c:AddCounter(0x1115,1)
	end
end
function cid.uatarget(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsAttribute(ATTRIBUTE_EARTH)
end
function cid.uavalue(e,c)
	return e:GetHandler():GetCounter(0x1115)*600
end
function cid.eacondition(e,tp)
	return e:GetHandler():GetCounter(0x1115)>1
end
function cid.eatarget(e,c)
	return e:GetHandler():GetMutualLinkedGroup():IsContains(c) and c:IsAttribute(ATTRIBUTE_EARTH)
end
