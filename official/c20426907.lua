--機殻の再星
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON)
	e1:SetTarget(s.distg1)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.distg2)
	e2:SetOperation(s.disop)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.distg3)
	e4:SetOperation(s.disop)
	e4:SetLabel(2)
	c:RegisterEffect(e4)
	--tograve
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_SELF_TOGRAVE)
	e5:SetCondition(s.sdcon)
	c:RegisterEffect(e5)
end
s.listed_names={id}
s.listed_series={0xaa}
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and not c:IsType(TYPE_NORMAL)
end
function s.distg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SUMMON_SUCCESS,true)
	if not res then
		res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_FLIP_SUMMON_SUCCESS,true)
	end
	if res then
		local tc=teg:GetFirst()
		if tc:IsLevelBelow(4) and not tc:IsType(TYPE_NORMAL)
			and Duel.SelectYesNo(tp,94) then
			e:SetLabel(1)
			Duel.SetTargetCard(teg)
			Duel.SetOperationInfo(0,CATEGORY_DISABLE,teg,1,0,0)
			e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
		end
		return
	end
	res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if res then
		local g=teg:Filter(s.filter,nil)
		if #g>0 and Duel.SelectYesNo(tp,94) then
			e:SetLabel(2)
			Duel.SetTargetCard(g)
			Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
			e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
		end
	end
end
function s.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetFirst():IsLevelBelow(4) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.distg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(aux.FilterFaceupFunction(Card.IsLevelAbove,5),1,nil) end
	local g=eg:Filter(aux.FilterFaceupFunction(Card.IsLevelAbove,5),nil)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.disfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.disfilter,nil,e)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if e:GetLabel()==2 then
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e3:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e3)
		end
	end
end
function s.sdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaa) and not c:IsCode(id)
end
function s.sdcon(e)
	return not Duel.IsExistingMatchingCard(s.sdfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
