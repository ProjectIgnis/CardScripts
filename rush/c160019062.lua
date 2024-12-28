--骸の群れ
--Skeletal Swarm
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Decrease the ATK of an opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local atkr=Duel.GetAttacker()
	return atkr and atkr:IsControler(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_SKULL_SERVANT)
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,-1000*ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local tc=Duel.GetAttacker()
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_SKULL_SERVANT)
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() and ct>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000*ct)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end