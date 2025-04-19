--冥骸デッド・ルーラー
--Dark Doom Dread Ruler
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK by 1000 then inflict 700 damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,1000)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,700)
end
function s.zmbfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevel(7)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
		--Effect
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) and c:UpdateAttack(1000,RESETS_STANDARD_PHASE_END)==1000
			and Duel.IsExistingMatchingCard(s.zmbfilter,tp,LOCATION_GRAVE,0,1,nil) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,700,REASON_EFFECT)
		end
	end
end