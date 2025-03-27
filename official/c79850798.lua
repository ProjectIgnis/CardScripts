--爆走特急ロケット・アロー
--Rocket Arrow Express
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Special Summoning condition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--Cannot activate cards or effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Cannot Set cards
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_MSET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(aux.TRUE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e7:SetTarget(function(_,_,_,_,sumpos) return (sumpos&POS_FACEDOWN)>0 end)
	c:RegisterEffect(e7)
	--Maintenance cost
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e8:SetOperation(s.mtop)
	c:RegisterEffect(e8)
	--Check/apply Battle Phase restriction
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e9:SetCode(EFFECT_SPSUMMON_COST)
	e9:SetCost(function(_,_,tp) return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end)
	e9:SetOperation(s.spcostop)
	c:RegisterEffect(e9)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #hg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.SendtoGrave(hg,REASON_COST)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
function s.spcostop(e,tp,eg,ep,ev,re,r,rp)
	--Cannot conduct your Battle Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end