--Rainbow End Dragon
--designed by Gideon
--scripted by Larry126
function c210002857.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(c210002857.spcon)
	e1:SetOperation(c210002857.spop)
	c:RegisterEffect(e1)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	--win
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c210002857.winop)
	c:RegisterEffect(e4)
	if not c210002857.global_check then
		c210002857.global_check=true
		local e1=Effect.CreateEffect(c) 
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetCondition(c210002857.sprcon)
		e1:SetOperation(c210002857.sprop)
		Duel.RegisterEffect(e1,0)
	end
end
function c210002857.cfilter(c)
	local code1,code2=c:GetOriginalCodeRule()
	return code1==79407975 or code2==79407975
end
function c210002857.sprcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210002857.cfilter,1,nil) and Duel.IsPlayerAffectedByEffect(tp,69832741)
end
function c210002857.sprop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) or not eg:IsExists(c210002857.cfilter,1,nil) then return end
	local g=eg:Filter(c210002857.cfilter,nil)
	for c in aux.Next(g) do
		if re:GetCode()==34 and re:GetOwner()==c then
			c:RegisterFlagEffect(210002857,RESET_EVENT+0x1fe0000,0,1)
		end
	end
end
function c210002857.spfilter(c,tp,sc)
	local sg=Group.FromCards(c)
	local code1,code2=c:GetOriginalCodeRule()
	return c:IsAbleToGraveAsCost() and (code1==79407975 or code2==79407975)
		and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
		and c:GetFlagEffect(210002857)>0
end
function c210002857.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(c210002857.spfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function c210002857.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c210002857.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	Duel.SendtoGrave(g,REASON_COST)
end
function c210002857.winop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetSummonPlayer()
	Duel.Win(p,REASON_EFFECT)
end