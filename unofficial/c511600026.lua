--Cynet Refresh
--サイバネット・リフレッシュ
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsRace(RACE_CYBERSE)
end
function s.desfilter(c,e,tp)
	return c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 or #g==0 then
		local sg=Duel.GetOperatedGroup()
		sg:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(sg)
		e1:SetOperation(s.spop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,c:GetControler())
		and c:IsLocation(LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(s.spfilter,nil,e,tp)
	if #g==0 then return end
	for p=0,1 do
		local tg=g:Filter(Card.IsControler,nil,p)
		local lc=Duel.GetLocationCount(p,LOCATION_MZONE)
		if #tg>lc then
			tg=tg:Select(tp,lc,lc,nil)
		end
		for tc in aux.Next(tg) do
			Duel.SpecialSummonStep(tc,0,tp,p,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
end
--------------------------------------------------------
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.filter)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.filter(e,c)
	return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster()
end
function s.efilter(e,te,c)
	return te:GetOwner()~=c
end