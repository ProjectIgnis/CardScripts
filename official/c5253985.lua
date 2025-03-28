--交差する魂
--Soul Crossing
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function()return Duel.IsMainPhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
function s.chainfilter(re,tp,cid)
	if Duel.GetFlagEffect(tp,id)==0 then return true end
	return not (re:IsSpellTrapEffect() or not re:GetHandler():IsRace(RACE_DIVINE))
end
function s.filter(c,e,ec)
	if not c:IsRace(RACE_DIVINE) then return false end
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(POS_FACEUP)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1,true)
	local res=c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1)
	e1:Reset()
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,c):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(POS_FACEUP)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local s1=tc:IsSummonable(true,nil,1)
		local s2=tc:IsMSetable(true,nil,1)
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EVENT_SUMMON_SUCCESS)
			e2:SetOperation(s.sumsuc)
			e2:SetLabel(tp)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
			tc:RegisterEffect(e2,true)
			Duel.Summon(tp,tc,true,nil,1)
		else
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EVENT_MSET)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
			e3:SetOperation(s.sumsuc)
			e3:SetLabel(tp)
			tc:RegisterEffect(e3,true)
			Duel.MSet(tp,tc,true,nil,1)
		end
	end
end
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local player=e:GetLabel()
	if e:GetHandler():GetMaterial():IsExists(Card.IsPreviousControler,1,nil,1-player) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetCondition(s.accon)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,player)
		Duel.RegisterFlagEffect(player,id,RESET_PHASE|PHASE_END,0,2)
	end
end
function s.accon(e)
	return Duel.GetCustomActivityCount(id,e:GetHandlerPlayer(),ACTIVITY_CHAIN)>0
end
function s.aclimit(e,re,tp)
	return re:IsSpellTrapEffect() or not re:GetHandler():IsRace(RACE_DIVINE)
end