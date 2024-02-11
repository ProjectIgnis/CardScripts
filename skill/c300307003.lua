--Whale of a Tale
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={62337487,77454922} --Fortress Wahle, Fortress Whale's Oath
s.listed_series={SET_FORTRESS_WHALE}
function s.thfilter(c)
	return c:IsCode(62337487,77454922) and c:IsAbleToHand()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Discard 1 card to add "Fortress Whale" or "Fortress Whale's Oath" from Deck
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	--"Fortress Whale" monster protection effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER) end)
	e1:SetValue(s.ctval)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsFaceup() and c:IsMonster() and c:IsCode(62337487,96546575) end)
	e2:SetLabelObject(e1)
	Duel.RegisterEffect(e2,tp)
end
function s.ctval(e,re,rp)
	return re:IsSpellTrapEffect() and rp==1-e:GetHandlerPlayer()
end