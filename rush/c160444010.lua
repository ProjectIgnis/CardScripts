--三重騎
--Three Cavalteers
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Decrease the ATK of an opponent's monster by 1000
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
	local ac=Duel.GetAttacker()
	return ac:IsControler(1-tp) and ac:IsLevelAbove(7) and Duel.IsExistingMatchingCard(Card.IsLevelAbove,tp,LOCATION_GRAVE,0,3,nil,7)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=Duel.GetAttacker()
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,-1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local tc=Duel.GetAttacker()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end