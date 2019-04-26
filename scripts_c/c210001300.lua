--Trickstar Cattlerine
function c210001300.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,210001300)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c210001300.spcost)
	e1:SetTarget(c210001300.sptarget)
	e1:SetOperation(c210001300.spoperation)
	c:RegisterEffect(e1)
	--add attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c210001300.uatarget)
	e2:SetValue(c210001300.uavalue)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c210001300.damcon)
	e3:SetOperation(c210001300.damop)
	c:RegisterEffect(e3)
end
function c210001300.spcfilter(c)
	return c:IsSetCard(0xfb) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function c210001300.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(c210001300.spcfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0) end
	local sg=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function c210001300.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c210001300.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c210001300.ufilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfb)
end
function c210001300.uatarget(e,c)
	return c210001300.ufilter(c)
end
function c210001300.uavalue(e,c)
	return 100*Duel.GetMatchingGroupCount(c210001300.ufilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
function c210001300.cfilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function c210001300.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c210001300.cfilter,1,nil,1-tp)
end
function c210001300.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,210001300)
	Duel.Damage(1-tp,200,REASON_EFFECT)
end