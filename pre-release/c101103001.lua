--アームド・ドラゴン・サンダー LV10
--Armed Dragon Thunder LV10
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Register summon by an "Armed Dragon" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--ICHI - Treat name as "Armed Dragon LV10"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(59464593)
	e1:SetCondition(s.atkcon(1))
	c:RegisterEffect(e1)
	--JUU - Cannot change control
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e10:SetCondition(s.atkcon(10))
	c:RegisterEffect(e10)
	--HYAKU - Cannot be destroyed by battle
	local e100=Effect.CreateEffect(c)
	e100:SetType(EFFECT_TYPE_SINGLE)
	e100:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e100:SetRange(LOCATION_MZONE)
	e100:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e100:SetValue(1)
	e100:SetCondition(s.atkcon(100))
	c:RegisterEffect(e100)
	--SEN - Destroy 1 card and gain ATK
	local e1000=Effect.CreateEffect(c)
	e1000:SetDescription(aux.Stringid(id,0))
	e1000:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1000:SetType(EFFECT_TYPE_QUICK_O)
	e1000:SetCode(EVENT_FREE_CHAIN)
	e1000:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1000:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1000:SetRange(LOCATION_MZONE)
	e1000:SetCountLimit(1)
	e1000:SetCondition(s.descon)
	e1000:SetCost(s.descost)
	e1000:SetTarget(s.destg)
	e1000:SetOperation(s.desop)
	c:RegisterEffect(e1000)
	--MANJOUME THUNDER - Destroy all other cards on the field
	local e10000=Effect.CreateEffect(c)
	e10000:SetDescription(aux.Stringid(id,1))
	e10000:SetCategory(CATEGORY_DESTROY)
	e10000:SetType(EFFECT_TYPE_IGNITION)
	e10000:SetRange(LOCATION_MZONE)
	e10000:SetCountLimit(1)
	e10000:SetCondition(s.atkcon(10000))
	e10000:SetTarget(s.destg2)
	e10000:SetOperation(s.desop2)
	c:RegisterEffect(e10000)
end
s.listed_names={59464593}
s.listed_series={0x111}
s.LVnum=10
s.LVset=0x111
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x111)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end
function s.atkcon(atk)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:GetFlagEffect(id)>0 and c:IsAttackAbove(atk)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsTurnPlayer(tp) and s.atkcon(1000)(e,tp,eg,ep,ev,re,r,rp)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		e:GetHandler():UpdateAttack(1000)
	end
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
