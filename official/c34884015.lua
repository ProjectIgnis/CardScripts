--魂のペンデュラム
--Soul Pendulum
--scripted started by andré
local COUNTER_SOUL_PENDULUM=0x200
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SOUL_PENDULUM)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Change each Pendulum Scale by 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.cpstarget)
	e2:SetOperation(s.cpsoperation)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	--Each time your Pendulum Monster(s) is Pendulum Summoned, place 1 counter on this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.acotccondition)
	e3:SetOperation(s.acotcoperation)
	c:RegisterEffect(e3)
	--Pendulum Monsters on the field gain 300 ATK for each counter on this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetTarget(s.iatarget)
	e4:SetValue(s.iavalue)
	c:RegisterEffect(e4)
	--You can conduct 1 Pendulum Summon of a monster(s) in addition to your Pendulum Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.apscondition)
	e5:SetCost(s.apscost)
	e5:SetOperation(s.apsoperation)
	c:RegisterEffect(e5)
end
function s.cpstarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_PZONE,0,2,2,nil)
end
function s.getscale(c)
	if c==Duel.GetFieldCard(0,LOCATION_PZONE,0) or c==Duel.GetFieldCard(1,LOCATION_PZONE,0) then
		return c:GetLeftScale()
	else
		return c:GetRightScale()
	end
end
function s.cpsoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e)
	for tc in tg:Iter() do
		Duel.HintSelection(Group.FromCards(tc))
		Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())
		local scale = s.getscale(tc)
		local opt = (scale <= 1) and 1 or 2
		if opt == 2 then
			opt = Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		else
			opt = Duel.SelectOption(tp,aux.Stringid(id,1))
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue((opt==0) and 1 or -1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
function s.acotcfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsSummonPlayer(tp) and c:IsPendulumSummoned()
end
function s.acotccondition(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.acotcfilter,1,nil,tp)
end
function s.acotcoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(COUNTER_SOUL_PENDULUM,1)
end
function s.iatarget(e,c)
	return c:IsMonster() and c:IsType(TYPE_PENDULUM)
end
function s.iavalue(e,c)
	return e:GetHandler():GetCounter(COUNTER_SOUL_PENDULUM)*300
end
function s.apscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_SOUL_PENDULUM,3,REASON_COST) end
	c:RemoveCounter(tp,COUNTER_SOUL_PENDULUM,3,REASON_COST)
end
function s.apscondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,29432356)==0
end
function s.apsoperation(e,tp,eg,ep,ev,re,r,rp)
	Pendulum.RegisterAdditionalPendulumSummon(e:GetHandler(),tp,id,aux.Stringid(id,4))
end