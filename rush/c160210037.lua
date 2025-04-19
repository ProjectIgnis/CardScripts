--超銀河王ロード・オブ・ギャラクティカ［Ｌ］
--Super Galaxy King Lord of Galactica [L]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of your monsters lose 4000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Left"
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY|RACE_DRAGON|RACE_MACHINE|RACE_SPELLCASTER)
		and c:IsAttackAbove(4000) and c:GetBaseAttack()>=4000 and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		--Loses 4000 ATK
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-4000)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,nil)
			if #g>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				sg=g:Select(tp,1,4,nil)
				sg=sg:AddMaximumCheck()
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end