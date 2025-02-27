--幻撃竜ミラギアス
--Illusion Strike Dragon Miragias
local s,id=GetID()
function s.initial_effect(c)
	--Up to 2 face-up Level 7 or lower monsters on your opponent's field lose 1500 ATK until the end of this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(7) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.atkfilter(c)
	return c:IsMonster() and c:IsFaceup() and c:GetAttack()>0 and c:IsLevelBelow(7)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,2,nil)
			if #g2>0 then
				for tc in g2:Iter() do
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(-1500)
					e1:SetReset(RESETS_STANDARD_PHASE_END)
					tc:RegisterEffect(e1)
				end
				--Can make a second attack on monsters during the Battle Phase
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
				e1:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id+1) end)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
				e1:SetValue(1)
				c:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_BATTLE_DESTROYING)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCondition(aux.bdcon)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
				e2:SetOperation(s.bdop)
				c:RegisterEffect(e2)
			end
		end
	end
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+1,RESETS_STANDARD_PHASE_END,0,1)
end