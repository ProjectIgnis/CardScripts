--黒魔術のバリア －ミラーフォース－
--Dark Magic Mirror Force
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate (on attack)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activate (on effect)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.effcon)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_SHINING_SARCOPHAGUS}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.ListsCode,CARD_SHINING_SARCOPHAGUS),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsMonsterEffect()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.ListsCode,CARD_SHINING_SARCOPHAGUS),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)) then return false end
	local ex,tg,ct=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and ct+tg:FilterCount(aux.AND(Card.IsOnField,Card.IsMonster),nil)-#tg>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
	local ct=0
	if #g>0 then ct=Duel.Destroy(g,REASON_EFFECT) end
	if ct>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DARK_MAGICIAN),tp,LOCATION_MZONE,0,1,nil) then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local c=e:GetHandler()
	--The first time each monster you control that mentions "Shining Sarcophagus" would be destroyerd by battle or card effect, it is not destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.ListsCode,CARD_SHINING_SARCOPHAGUS))
	e1:SetValue(function(e,re,r,rp) return r&(REASON_BATTLE|REASON_EFFECT)>0 and 1 or 0 end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))
end