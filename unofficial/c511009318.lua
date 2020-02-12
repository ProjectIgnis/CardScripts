--Performapal Pendulum Art and Clean
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:GetLevel()==1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(24919805,1))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1)
		e1:SetCondition(s.descon)
		e1:SetCost(s.descost)
		e1:SetTarget(s.destg)
		e1:SetOperation(s.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCountFromEx(tp)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
	local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,ft,ft,nil,e,tp)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1) 
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DIRECT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
	Duel.SpecialSummonComplete()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RULE)
end
function s.cfilter(c)
	return c:IsSetCard(0x9f) and c:IsAbleToDeckAsCost() 
		and Duel.IsExistingMatchingCard(Card.IsStatus,0,LOCATION_MZONE,LOCATION_MZONE,1,c,STATUS_SPSUMMON_TURN)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsStatus,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,STATUS_SPSUMMON_TURN) end
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,LOCATION_MZONE,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsStatus,tp,LOCATION_MZONE,LOCATION_MZONE,nil,STATUS_SPSUMMON_TURN)
	Duel.Destroy(g,REASON_EFFECT)
end
