--スキエルＣ５ (TF6)
--Skiel Carrier 5 (TF6)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--selfdes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.sdcon)
	c:RegisterEffect(e2)
	--battle target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.cbcon)
	e3:SetOperation(s.cbop)
	c:RegisterEffect(e3)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.listed_series={0x3013}
s.listed_names={100000046}
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),Card.IsCode,1,false,1,true,c,c:GetControler(),nil,false,nil,100000046)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,false,true,true,c,nil,nil,false,nil,100000046)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x3013),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(tp)
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsRelateToBattle() and tc:IsControler(tp)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
		and bc:IsType(TYPE_MONSTER) and bc:IsPreviousControler(1-tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
