--ダークネス・アイ
--Darkness Eye
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Reveal cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.rvtg)
	e1:SetOperation(s.rvop)
	c:RegisterEffect(e1)
	--Normal Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
function s.rvtg(e,tp,ev,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_SZONE,0,1,nil) end
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos() and Duel.IsTurnPlayer(tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Decrease Tribute
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsLevelAbove(5)
end