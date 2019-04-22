--Jubilee Elemelon Prismelon
--AlphaKretin
function c210310004.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c210310004.disable)
	e1:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e1)
	--shuffle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4031,6))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c210310004.shtg)
	e2:SetOperation(c210310004.shop)
	c:RegisterEffect(e2)
	--revive
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4031,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EVENT_FLAG_DELAY)
	e3:SetCountLimit(1,210310004)
	e3:SetCondition(c210310004.revcon)
	e3:SetCost(c210310004.revcost)
	e3:SetTarget(c210310004.revtg)
	e3:SetOperation(c210310004.revop)
	c:RegisterEffect(e3)
	--other revive
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4031,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,210310004)
	e4:SetCondition(c210310004.spcon)
	e4:SetTarget(c210310004.sptg)
	e4:SetOperation(c210310004.spop)
	c:RegisterEffect(e4)
end
function c210310004.disable(e,c)
	local cg=e:GetHandler():GetColumnGroup()
	return (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT) and not c:IsAttribute(ATTRIBUTE_LIGHT) and cg:IsContains(c) and not c:IsControler(tp)
end
function c210310004.shmzonefilter(c)
	return c:IsSetCard(0xf31) and c:IsFaceup()
end
function c210310004.shgravefilter(c)
	return c:IsSetCard(0xf31) and c:IsType(TYPE_MONSTER)
end
function c210310004.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210310004.shgravefilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingMatchingCard(c210310004.shmzonefilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function c210310004.shval(e)
	local tp=e:GetHandlerPlayer()
	local att=0
	for i=0,4 do
		local tc=Duel.GetFieldCard(tp,LOCATION_MZONE,i)
		if tc and tc:IsFaceup() and tc:IsSetCard(0xf31) then att=bit.bor(att,tc:GetAttribute()) end
	end
	local ct=0
	while att~=0 do
		if bit.band(att,0x1)~=0 then ct=ct+1 end
		att=bit.rshift(att,1)
	end
	return ct
end
function c210310004.shval2(g)
	local att=0
	for tc in aux.Next(g) do
		if tc and tc:IsSetCard(0xf31) and tc:IsType(TYPE_MONSTER) then att=bit.bor(att,tc:GetAttribute()) end
	end
	local ct=0
	while att~=0 do
		if bit.band(att,0x1)~=0 then ct=ct+1 end
		att=bit.rshift(att,1)
	end
	return ct
end
function c210310004.shop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Destroy(c,REASON_EFFECT) then
		local num=c210310004.shval(e)
		local g=Duel.SelectMatchingCard(tp,c210310004.shgravefilter,tp,LOCATION_GRAVE,0,1,num,nil)
		g:KeepAlive()
		if Duel.SendtoDeck(g,tp,0,REASON_EFFECT) then
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			local num2=c210310004.shval2(g)
			local tg=Duel.GetMatchingGroup(c210310004.shmzonefilter,tp,LOCATION_MZONE,0,nil)
			for tc in aux.Next(tg) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(400*num2)
				e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e1)
				tc:RegisterEffect(e2)
			end
		end
	end
end
function c210310004.revcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c210310004.revcostfilter(c,attr)
	if not c:IsSetCard(0xf31) or c:IsAttribute(attr) or not c:IsAbleToRemoveAsCost() or not c:IsType(TYPE_MONSTER) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return not Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	else
		return Duel.IsPlayerAffectedByEffect(c:GetControler(),69832741)
	end
end
function c210310004.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c210310004.revcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c,c:GetAttribute()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c210310004.revcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c,c:GetAttribute())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c210310004.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210310004.revop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function c210310004.cfilter(c,tp,attr)
	return c:IsSetCard(0xf31) and c:GetAttribute()~=attr and c:IsPreviousLocation(LOCATION_GRAVE)
		and c:GetPreviousControler()==tp
end
function c210310004.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c210310004.cfilter,1,nil,tp,e:GetHandler():GetAttribute())
end
function c210310004.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210310004.ccost(e,c,tp)
	return Duel.CheckLPCost(tp,1000)
end
function c210310004.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,1000)
end
function c210310004.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+0x47e0000)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SPSUMMON_COST)
		e2:SetTargetRange(LOCATION_EXTRA,0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCost(c210310004.ccost)
		e2:SetOperation(c210310004.acop)
		Duel.RegisterEffect(e2,tp)
	end
end
