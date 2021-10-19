-- ヘッドバッドキャシャロット
-- Headbutt Cachalot
local s,id=GetID()
function s.initial_effect(c)
	-- atk + damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return 
		Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsFaceup),tp,0,LOCATION_MZONE,1,nil) 
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
		-- Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsFaceup),tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			-- Piercing
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			g:GetFirst():RegisterEffectRush(e1)
			local ct=Duel.GetMatchingGroupCount(s.fupfilter,tp,LOCATION_ONFIELD,0,nil)
			if ct>0 then
				Duel.Damage(1-tp,500,REASON_EFFECT)
			end
		end
end

function s.fupfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_UMI) or c:IsCode(CARD_BIG_OCEAN))
end