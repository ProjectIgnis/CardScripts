--Baldr of the Nordic Champions
--designed by Thaumablazer#4134, scripted by Naim
function c210777077.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x42),2)
	c:EnableReviveLimit()
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c210777077.protcon)
	e1:SetTarget(c210777077.prottg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Special Summon (ignition)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777077,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,210777077+100)
	e2:SetCondition(c210777077.spcon)
	e2:SetTarget(c210777077.sptg)
	e2:SetOperation(c210777077.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c210777077.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--special summon (tribute)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210777077,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCost(c210777077.cost)
	e4:SetCountLimit(1,210777077+200)
	e4:SetCondition(c210777077.spcon2)
	e4:SetTarget(c210777077.sptg2)
	e4:SetOperation(c210777077.spop2)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
end
function c210777077.protfil(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
function c210777077.protcon(e)
	return e:GetHandler():GetLinkedGroup():IsExists(c210777077.protfil,1,nil)
end
function c210777077.prottg(e,c)
	return c~=e:GetHandler()
end
function c210777077.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
function c210777077.filter(c,e,tp)
	return c:IsSetCard(0x42) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210777077.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210777077.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c210777077.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c210777077.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c210777077.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_LINK) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c210777077.costfilter(c,ft,tp)
	return c:IsFaceup() and (c:IsSetCard(0x4b) or c:IsSetCard(0x42))
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
function c210777077.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,c210777077.costfilter,1,false,nil,nil,ft,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,c210777077.costfilter,1,1,false,nil,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function c210777077.lvfieldfilter(c,e,tp)
	return c:IsSetCard(0x4b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
function c210777077.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210777077.lvfieldfilter,1,nil,e,tp)
end
function c210777077.spbfilter(c,e,tp)
	return c:IsSetCard(0x4b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
function c210777077.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local a1=Group.Filter(eg,c210777077.spbfilter,nil,e,tp)
	Debug.Message(e:GetHandler():GetSequence()<5)
	if chk==0 then 
		if e:GetHandler():GetSequence()>5 then 
			return	Duel.GetLocationCount(tp,LOCATION_MZONE)>=#a1 else
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>=(#a1)-1
			end
	end
	Duel.SetTargetCard(a1)
	Debug.Message(#a1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,a1,1,0,0)
end
function c210777077.spop2(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc and tc:IsRelateToEffect(e) do
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc=g:GetNext()
	end
end
