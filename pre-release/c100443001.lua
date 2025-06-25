--恋する乙女
--Maiden in Love
--scripted by Naim
local s,id=GetID()
local COUNTER_MAIDEN=0x1090
function s.initial_effect(c)
	--Monsters your opponent controls that can attack must attack this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_MUST_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2:SetValue(function(e,c) return c==e:GetHandler() end)
	c:RegisterEffect(e2)
	--Cannot be destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Activate 1 of these effects at the end of the Damage Step, if this card battled an opponent's monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.effcon)
	e4:SetTarget(s.efftg)
	e4:SetOperation(s.effop)
	c:RegisterEffect(e4)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetBattleTarget() and c:IsStatus(STATUS_OPPO_BATTLE)
end
function s.controlfilter(c)
	return c:HasCounter(COUNTER_MAIDEN) and c:IsControlerCanBeChanged()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,COUNTER_MAIDEN,1)
	local b2=Duel.IsExistingMatchingCard(s.controlfilter,tp,0,LOCATION_MZONE,1,nil)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_MZONE) and c:IsRelateToBattle() and (b1 or b2) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_COUNTER)
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,COUNTER_MAIDEN)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		local g=Duel.GetMatchingGroup(s.controlfilter,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Place 1 Maiden Counter on 1 face-up monster your opponent controls.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		local sc=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,COUNTER_MAIDEN,1):GetFirst()
		if sc then
			sc:AddCounter(COUNTER_MAIDEN,1)
		end
	elseif op==2 then
		--Take control of 1 opponent's monster with a Maiden Counter.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local sc=Duel.SelectMatchingCard(tp,s.controlfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if sc then
			Duel.GetControl(sc,tp)
		end
	end
end