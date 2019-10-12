--ＡｉＡｉウォール
--A.I. A.I. Wall
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x584)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82821760,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.condition)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition)
	e3:SetValue(s.indval)
	c:RegisterEffect(e3)
	--cannot declare attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetCondition(s.condition)
	c:RegisterEffect(e4)
	--add counter
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(82821760,0))
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1)
	e5:SetCondition(s.accon)
	e5:SetOperation(s.acop)
	c:RegisterEffect(e5)
	--remove counter
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(82821760,1))
	e6:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetCondition(s.condition)
	e6:SetOperation(s.rcop)
	c:RegisterEffect(e6)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLinkMonster() and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		c:AddCounter(0x584,tc:GetLink())
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x584)>0
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.acfilter(c,p)
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetSummonPlayer()==p
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.acfilter,1,nil,1-tp) and s.condition(e,tp,eg,ep,ev,re,r,rp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:AddCounter(0x584,1)
	end
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:RemoveCounter(tp,0x584,1,REASON_EFFECT)
	end
end
