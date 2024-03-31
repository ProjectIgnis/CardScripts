--トランザム・V(ヴァリュアブル)・ライナック
-- Transamu Valuable Rainac
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_TRANSAMU_RAINAC,1,s.ffilter,1)
	--atk increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.named_material={CARD_TRANSAMU_RAINAC}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,scard,sumtype,tp) and c:IsRace(RACE_GALAXY,fc,sumtype,tp) and c:IsLevel(7)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsRace(RACE_GALAXY) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.cfilter(c)
	return c:IsLevel(7) and c:IsType(TYPE_EFFECT) and c:IsMonster()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if #g1==0 then return end
	Duel.HintSelection(g1,true)
	Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_EFFECT)
	local g2=Duel.GetOperatedGroup()
	if g2:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
	end
	-- Effect
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		e1:SetValue(1400)
		c:RegisterEffect(e1)
		--if you shuffled 2 Level 7 Effect monsters
		if g2:FilterCount(s.cfilter,nil)==2 then
			--Cannot be destroyed battle
			local e2=e1:Clone()
			e2:SetDescription(3000)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetValue(1)
			c:RegisterEffect(e2)
			--Cannot be destroyed by opponent's trap
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(3012)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e3:SetValue(s.indval)
			e3:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e3)
			--attack twice
			local e4=Effect.CreateEffect(c)
			e4:SetDescription(3201)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e4:SetCode(EFFECT_EXTRA_ATTACK)
			e4:SetValue(1)
			e4:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e4)
		end
	end
end
function s.indval(e,re,rp)
	return re:IsTrapEffect() and re:GetOwnerPlayer()~=e:GetOwnerPlayer()
end