--放電ムスタンガン
--Zap Mustung
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(2)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
	--spsummon limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.limittg)
	c:RegisterEffect(e3)
	--counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.countcon1)
	e4:SetValue(s.countval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCondition(s.countcon2)
	e5:SetTargetRange(0,1)
	c:RegisterEffect(e5)
end
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS) and Duel.GetActivityCount(e:GetHandlerPlayer(),ACTIVITY_SPSUMMON)==0
		and Duel.IsPhase(PHASE_MAIN1) and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end
function s.limittg(e,c,tp)
	return Duel.IsTurnPlayer(tp) and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)>=Duel.GetBattledCount(tp)
end
function s.countcon1(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.countcon2(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function s.countval(e,re,tp)
	local t1=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	local t2=Duel.GetBattledCount(tp)
	if t1>=t2 then return 0 else return t2-t1 end
end