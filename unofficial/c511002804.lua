--刹那の調律
--Flash Tune
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
function s.spfilter(c,mg,e,tp)
	if not (c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp,tp,mg,c)) then return false end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetLabelObject(c)
	e1:SetTarget(s.sumlimit)
	e1:SetTargetRange(1,0)
	e1:SetValue(POS_FACEUP_ATTACK)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	local chk=c:IsSynchroSummonable(mg)
	e1:Reset()
	return chk
end
function s.filter(c,mg,e,tp)
	return c:IsType(TYPE_TUNER) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,mg+c,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(Card.IsType,nil,TYPE_SYNCHRO)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,g,e,tp) end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(Card.IsType,nil,TYPE_SYNCHRO):Filter(Card.IsRelateToEffect,nil,e)
	if #tg<=0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,tg,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local tuner=g:Select(tp,1,1,nil):GetFirst()
		local mg=tg+tuner
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg,e,tp):GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetLabelObject(sc)
		e1:SetCondition(s.sumcon)
		e1:SetTarget(s.sumlimit)
		e1:SetTargetRange(1,0)
		e1:SetValue(POS_FACEUP_ATTACK)
		sc:CreateEffectRelation(e1)
		Duel.RegisterEffect(e1,tp)
		Duel.SynchroSummon(tp,sc,mg)
	end
end
function s.sumcon(e)
	if e:GetLabelObject():IsRelateToEffect(e) then
		return true
	else
		e:SetLabelObject(nil)
		e:Reset()
		return false
	end
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c==e:GetLabelObject()
end