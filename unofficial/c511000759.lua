--インスタント・チューン
--Instant Tune
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		Duel.RegisterFlagEffect(ec:GetControler(),id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,id)>0
end
function s.filter(c,tp,mg,ec)
	return c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0 and c:IsSynchroSummonable(ec,mg)
end
s.matfilter=aux.FaceupFilter(Card.IsCanBeSynchroMaterial)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SYNCHRO_LEVEL)
		e2:SetValue(1)
		c:RegisterEffect(e2)
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,tp,mg,e:GetHandler())
		e1:Reset()
		e2:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_MONSTER+TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tp,mg,e:GetHandler()):GetFirst()
	if sc then
		c:CancelToGrave()
		Duel.SynchroSummon(tp,sc,c,mg)
	end
end