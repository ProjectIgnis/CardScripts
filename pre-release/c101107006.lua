--氷水帝コスモクロア
--Cosmocroix the Icejade Imperatrix
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--cannot activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.accon)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	--change atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
end
s.listed_names={101107052}
s.listed_series={0x16e}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.accon(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,101107052),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	local status=STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLocation(LOCATION_MZONE)
		and not rc:IsStatus(status)
end
function s.atkcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()
end
function s.atktg(e,c)
	local tp=e:GetHandlerPlayer()
	local bc=c:GetBattleTarget()
	return c:IsControler(1-tp) and bc:IsSetCard(0x16e) and bc:IsControler(tp)
end