--Clear World (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--adjust
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.adjustop)
	c:RegisterEffect(e3)
	--light
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_PUBLIC)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e4:SetTarget(s.lighttg)
	c:RegisterEffect(e4)
	--dark
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.darkcon1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCondition(s.darkcon2)
	e6:SetTargetRange(0,1)
	c:RegisterEffect(e6)
	--earth
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(74131780,0))
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e7:SetCondition(s.descon)
	e7:SetTarget(s.destg)
	e7:SetOperation(s.desop)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetRange(LOCATION_SZONE)
	e8:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e8:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e8:SetCondition(s.descon)
	e8:SetTarget(s.destg2)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)
	--water
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,2))
	e9:SetCategory(CATEGORY_HANDES)
	e9:SetCode(EVENT_PHASE+PHASE_END)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e9:SetRange(LOCATION_SZONE)
	e9:SetProperty(EFFECT_FLAG_REPEAT)
	e9:SetCountLimit(1)
	e9:SetCondition(s.hdcon)
	e9:SetTarget(s.hdtg)
	e9:SetOperation(s.hdop)
	c:RegisterEffect(e9)
	--fire
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,3))
	e10:SetCategory(CATEGORY_DAMAGE)
	e10:SetCode(EVENT_PHASE+PHASE_END)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e10:SetRange(LOCATION_SZONE)
	e10:SetProperty(EFFECT_FLAG_REPEAT)
	e10:SetCountLimit(1)
	e10:SetCondition(s.damcon)
	e10:SetTarget(s.damtg)
	e10:SetOperation(s.damop)
	c:RegisterEffect(e10)
	--wind
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_CANNOT_ACTIVATE)
	e11:SetRange(LOCATION_SZONE)
	e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e11:SetTargetRange(1,0)
	e11:SetCondition(s.windcon1)
	e11:SetValue(s.actlimit)
	c:RegisterEffect(e11)
	local e12=e11:Clone()
	e12:SetTargetRange(0,1)
	e12:SetCondition(s.windcon2)
	c:RegisterEffect(e12)
end
s[0]=0
s[1]=0
function s.raccheck(p)
	local rac=0
	local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		rac=(rac|tc:GetAttribute())
	end
	s[p]=rac
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(0,97811903) then
		s.raccheck(0)
	else s[0]=0 end
	if not Duel.IsPlayerAffectedByEffect(1,97811903) then
		s.raccheck(1)
	else s[1]=0 end
end
function s.lighttg(e,c)
	return (s[c:GetControler()]&ATTRIBUTE_LIGHT)~=0
end
function s.darkcon1(e)
	return (s[e:GetHandlerPlayer()]&ATTRIBUTE_DARK)~=0
end
function s.darkcon2(e)
	return (s[1-e:GetHandlerPlayer()]&ATTRIBUTE_DARK)~=0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return (s[Duel.GetTurnPlayer()]&ATTRIBUTE_EARTH)~=0 and Duel.GetTurnPlayer()==tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if (s[Duel.GetTurnPlayer()]&ATTRIBUTE_EARTH)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return (s[Duel.GetTurnPlayer()]&ATTRIBUTE_WATER)~=0
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local turnp=Duel.GetTurnPlayer()
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,turnp,1)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if (s[Duel.GetTurnPlayer()]&ATTRIBUTE_WATER)==0 then return end
	Duel.DiscardHand(Duel.GetTurnPlayer(),nil,1,1,REASON_EFFECT+REASON_DISCARD)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return (s[Duel.GetTurnPlayer()]&ATTRIBUTE_FIRE)~=0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local turnp=Duel.GetTurnPlayer()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,turnp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if (s[Duel.GetTurnPlayer()]&ATTRIBUTE_FIRE)==0 then return end
	Duel.Damage(Duel.GetTurnPlayer(),1000,REASON_EFFECT)
end
function s.windcon1(e)
	return (s[e:GetHandlerPlayer()]&ATTRIBUTE_WIND)~=0
end
function s.windcon2(e)
	return (s[1-e:GetHandlerPlayer()]&ATTRIBUTE_WIND)~=0
end
function s.actlimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:GetHandler():IsType(TYPE_SPELL)
end
