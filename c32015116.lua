--無差別破壊
--Blind Destruction
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--roll and destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(s.rdcon)
	e2:SetTarget(s.rdtg)
	e2:SetOperation(s.rdop)
	c:RegisterEffect(e2)
end
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.rdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.rdfilter(c,lv)
	if lv<6 then
		return c:IsFaceup() and c:GetLevel()==lv
	else
		return c:IsFaceup() and c:GetLevel()>=6 end
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local d1=Duel.TossDice(tp,1)
	local g=Duel.GetMatchingGroup(s.rdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,d1)
	Duel.Destroy(g,REASON_EFFECT)
end
