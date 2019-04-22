--XDi・アダプター
--Extra-Dimension Adapter
--Created and scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	Duel.PayLPCost(tp,1500)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local ctps={TYPE_FUSION , TYPE_SYNCHRO , TYPE_XYZ , TYPE_LINK }
	local cstps={SUMMON_TYPE_FUSION , SUMMON_TYPE_SYNCHRO , SUMMON_TYPE_XYZ , SUMMON_TYPE_LINK }
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local attr=Duel.AnnounceAttribute(tp,1,0xff)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(tp,table.unpack({1056,1063,1073,1076}))+1
	local reteff=Effect.GlobalEffect()
	reteff:SetTarget(function() return {rc,attr,ctps[op],cstps[op]} end)
	e:SetLabelObject(reteff)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local filt=e:GetLabelObject():GetTarget()()
	local rc=filt[1]
	local attr=filt[2]
	local ct=filt[3]
	local st=filt[4]
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit(rc,attr,ct))
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.propval(attr))
		e1:SetOperation(s.propcon(st))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(s.propval(rc))
		tc:RegisterEffect(e2)
	end
end
function s.propcon(st)
	return function(scard,sumtype,tp)
		return sumtype&st==st
	end
end
function s.propval(rc)
	return function(e,c,rp)
		return rc
	end
end
function s.splimit(rc,attr,ct)
	return function(e,c)
		return not (c:IsRace(rc) and c:IsAttribute(attr) and c:IsType(ct)) 
			and c:IsLocation(LOCATION_EXTRA)
	end
end
