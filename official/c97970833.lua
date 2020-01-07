--ラスト・リゾート
--Last Resort
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={34487429}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c,tp)
	return c:IsCode(34487429) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	local canadd = fc and fc:IsFaceup() and Duel.IsPlayerCanDraw(1-tp,1)
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	if canadd and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
