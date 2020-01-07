--Over Tuning
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--spsummon
	local ec1=Effect.CreateEffect(e:GetHandler())
	ec1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ec1:SetCode(EVENT_SUMMON_SUCCESS)
	ec1:SetCondition(s.check)
	ec1:SetLabel(0)
	ec1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec1,tp)
	local ec2=ec1:Clone()
	ec2:SetCode(EVENT_SPSUMMON_SUCCESS)
	ec2:SetCondition(s.check2)
	ec2:SetLabelObject(ec1)
	Duel.RegisterEffect(ec2,tp)
	local ec3=ec2:Clone()
	ec3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	Duel.RegisterEffect(ec3,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	e2:SetLabelObject(ec1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.spcon2)
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EVENT_CHAIN_END)
	Duel.RegisterEffect(e4,tp)
	local e5=e2:Clone()
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	Duel.RegisterEffect(e5,tp)
	local e6=e2:Clone()
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	Duel.RegisterEffect(e6,tp)
	local e7=e2:Clone()
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetCountLimit(1)
	Duel.RegisterEffect(e7,tp)
	local e8=Effect.CreateEffect(e:GetHandler())
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_ADJUST)
	e8:SetValue(1)
	e8:SetLabelObject(ec1)
	e8:SetCondition(s.spcon)
	e8:SetOperation(s.regop)
	e8:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e8,tp)
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_TUNER)
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==2 then return end
	if eg:IsExists(s.cfilter,1,nil,tp) then
		e:SetLabel(1)
	end
end
function s.check2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()==2 then return end
	if eg:IsExists(s.cfilter,1,nil,tp) then
		e:GetLabelObject():SetLabel(1)
	end
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1 and Duel.GetCurrentChain()==0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=1 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(85602018,0)) then
		e:GetLabelObject():SetLabel(2)
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=1 then return end
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCountLimit(1)
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetCondition(s.spcon3)
	e1:SetOperation(s.spop3)
	e1:SetReset(RESET_EVENT+EVENT_ADJUST)
	tc:RegisterEffect(e1)
end
function s.spcon3(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetLabelObject():GetLabel()==1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	og:Merge(g)
	e:GetLabelObject():SetLabel(2)
end
