--Cyber dragon Null
function c210001400.initial_effect(c)
	--code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(70095154)
	c:RegisterEffect(e1)
	--spcost
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCountLimit(1,210001400)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c210001400.spcost)
	e2:SetTarget(c210001400.sptarget)
	e2:SetOperation(c210001400.spoperation)
	c:RegisterEffect(e2)
end
function c210001400.cfilter(c,e)
	return c:IsLevelAbove(2) and c:IsSetCard(0x1093) and not c:IsImmuneToEffect(e)
end
function c210001400.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210001400.cfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	local tc=Duel.SelectMatchingCard(tp,c210001400.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-1)
	tc:RegisterEffect(e1)
end
function c210001400.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c210001400.ctarget(e,c)
	return not c:IsFaceup() or not c:IsSetCard(0x1093)
end
function c210001400.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c210001400.ctarget)
	e1:SetLabel(tp)
	e1:SetValue(c210001400.synlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c210001400.synlimit(e,c)
	return c and c:IsControler(e:GetLabel())
end