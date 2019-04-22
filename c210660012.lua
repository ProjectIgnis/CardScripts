--Yubel of the Wicked
--concept by Gideon
--scripted by Larry126
function c210660012.initial_effect(c)
	c:EnableCounterPermit(0xf66)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,false,false,78371393,c210660012.matfilter)
	aux.AddContactFusion(c,c210660012.contactfil,c210660012.contactop,c210660012.splimit)
	--immunities
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
	--todeck
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_COUNTER)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetRange(LOCATION_MZONE)
	e7:SetOperation(c210660012.cop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e8)
	local e9=e7:Clone()
	e9:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e9)
	--win
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e10:SetCode(EVENT_ADJUST)
	e10:SetRange(LOCATION_MZONE)
	e10:SetOperation(c210660012.winop)
	c:RegisterEffect(e10)
end
function c210660012.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_WICKED_YUBEL = 0xf66
	local c=e:GetHandler()
	if c:GetCounter(0xf66)==3 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,210660009) then
		Duel.Win(tp,WIN_REASON_WICKED_YUBEL)
	end
end
-----------------------------------------------------------------
function c210660012.cfilter(c,tp)
	return c:IsFaceup() and c:GetSummonPlayer()==tp and c:IsCode(57793869,62180201,21208154)
end
function c210660012.cop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c210660012.cfilter,1,nil,tp) then
		local c=e:GetHandler()
		local g=eg:Filter(c210660012.cfilter,nil,tp)
		for tc in aux.Next(g) do
			if c:GetFlagEffect(tc:GetCode())==0 then
				c:AddCounter(0xf66,1)
				c:RegisterFlagEffect(tc:GetCode(),RESET_EVENT+0x1fe0000,0,1)
			end
		end
	end
end
-----------------------------------------------------------------
function c210660012.matfilter(c,fc,sumtype,tp)
	local code=c:GetOriginalCode()
	return code==57793869 or code==62180201 or code==21208154
end
function c210660012.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function c210660012.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function c210660012.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end